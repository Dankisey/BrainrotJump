local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WingsConfig = require(ReplicatedStorage.Configs.WingsConfig)
local WingButtonView = require(script.WingButtonView)

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local BaseFrame = {} :: ControllerTemplate.Type

local function updateDescritionView(self: ControllerTemplate.Type)
    local descriptionFrame = self._frame.Description
    descriptionFrame.Visible = true
    local actionButtonLabel = descriptionFrame.ActionButton.Label

    if self._currentSelectedName == self._currentWings.Value then
        actionButtonLabel.Text = "Equipped"
        self._isCurrentItemEquipped = true
        self._ownsCurrent = true
    elseif self._controllers.InventoryController:HasEquipment("Wings", self._currentSelectedName) then
        actionButtonLabel.Text = "Equip"
        self._isCurrentItemEquipped = false
        self._ownsCurrent = true
    else
        actionButtonLabel.Text = "Buy"
        self._isCurrentItemEquipped = false
        self._ownsCurrent = false
    end

    descriptionFrame.ItemFrame.Icon.Image = if self._ownsCurrent then WingsConfig.Wings[self._currentSelectedName].Icon else "rbxassetid://125352837907619"
end

local function fillItems(self: ControllerTemplate.Type)
    local scrollingFrame: ScrollingFrame = self._frame:WaitForChild("ScrollingFrame")
    local itemTemplate: Frame = scrollingFrame:WaitForChild("ItemTemplate")
    local sortedWings = self._utils.GetKeys(WingsConfig.Wings)

    table.sort(sortedWings, function(wingsNameA: string, wingsNameB: string)
        return WingsConfig.Wings[wingsNameA].PriceInCash < WingsConfig.Wings[wingsNameB].PriceInCash
    end)

    for i = 1, #sortedWings do
        local itemFrame = itemTemplate:Clone()
        itemFrame.Parent = scrollingFrame
        itemFrame.LayoutOrder = i

        local name = sortedWings[i]
        local robuxPrice

        if WingsConfig.Wings[name].ProductId then
            local info = self._utils.TryGetProductInfo(WingsConfig.Wings[name].ProductId, Enum.InfoType.Product)
            robuxPrice = if info then info.PriceInRobux else "???"
            self._robuxPrices[name] = robuxPrice
        end

        self._viewsPerName[name] = WingButtonView.new(itemFrame, name, self._controllers, self._utils, robuxPrice)

        itemFrame.Visible = true
        itemFrame.Name = name
    end
end

function BaseFrame:UpdateInfoFrame(newSelectedItem: string)
    if self._currentSelectedName == newSelectedItem then return end

    if self._currentSelectedName then
        self._viewsPerName[self._currentSelectedName]:Unselect()
    end

    self._viewsPerName[newSelectedItem]:Select()
    self._currentSelectedName = newSelectedItem

    local descriptionFrame = self._frame.Description
    descriptionFrame.ItemName.Text = WingsConfig.Wings[newSelectedItem].PublicName
    -- descriptionFrame.ItemName.TextColor3 = WingsConfig.Items[self._currentSelectedName].Rarity.Color
    -- descriptionFrame.ItemFrame.UIStroke.Color = WingsConfig.Items[self._currentSelectedName].Rarity.Color
    -- descriptionFrame.ItemFrame.UIGradient.Color = WingsConfig.Items[self._currentSelectedName].Rarity.Gradient
    descriptionFrame.Multiplier.Label.Text = string.format("Jump Power Multiplier: x%s", self._utils.FormatNumber(WingsConfig.Wings[newSelectedItem].JumpPowerMultiplier))

    if self._robuxPrices[newSelectedItem] then
        descriptionFrame.Cost.Icon.Image = "rbxasset://textures/ui/common/robux@3x.png"
        descriptionFrame.Cost.Label.Text = self._robuxPrices[newSelectedItem]
    else
        descriptionFrame.Cost.Icon.Image = "rbxassetid://80513201967002"
        descriptionFrame.Cost.Label.Text = self._utils.FormatNumber(WingsConfig.Wings[newSelectedItem].PriceInCash)
    end

    updateDescritionView(self)
end

function BaseFrame:AfterPlayerLoaded(player: Player)
    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.CloseButton, function()
        self._controllers.GuiController.WingsGui:Disable()
    end)

    fillItems(self)

    self._currentWings = player:WaitForChild("Equipment"):WaitForChild("Wing") :: StringValue

    if self._currentWings.Value and self._currentWings.Value ~= "" then
        self:UpdateInfoFrame(self._currentWings.Value)
    else
        self._frame.Description.Visible = false
    end

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.Description.ActionButton, function()
        if self._isCurrentItemEquipped then return end

        if self._ownsCurrent then
            self._controllers.InventoryController:TryEquipItem("Wings", self._currentSelectedName)
        else
            self._controllers.InventoryController:RequestItemUnlocking("Wings", self._currentSelectedName)
        end
    end)

    self._controllers.InventoryController.Updated:Subscribe(self, function()
        updateDescritionView(self)
    end)

    self._currentWings.Changed:Connect(function()
        updateDescritionView(self)
    end)
end

function BaseFrame.new(frame: Frame)
    local self = setmetatable(BaseFrame, {__index = ControllerTemplate})
    self._robuxPrices = {}
    self._viewsPerName = {}
    self._frame = frame

    return self
end

return BaseFrame