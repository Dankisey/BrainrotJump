local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BasketsConfig = require(ReplicatedStorage.Configs.BasketsConfig)
local BasketButtonView = require(script.BasketButtonView)

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local BaseFrame = {} :: ControllerTemplate.Type

local function updateDescritionView(self: ControllerTemplate.Type)
    local descriptionFrame = self._frame.Description
    local actionButtonLabel = descriptionFrame.ActionButton.Label

    if self._currentSelectedName == self._currentBasket.Value then
        actionButtonLabel.Text = "Equipped"
        self._isCurrentItemEquipped = true
        self._ownsCurrent = true
    elseif self._controllers.InventoryController:HasEquipment("Baskets", self._currentSelectedName) then
        actionButtonLabel.Text = "Equip"
        self._isCurrentItemEquipped = false
        self._ownsCurrent = true
    else
        actionButtonLabel.Text = "Buy"
        self._isCurrentItemEquipped = false
        self._ownsCurrent = false
    end

    descriptionFrame.ItemFrame.Icon.Image = if self._ownsCurrent then BasketsConfig.Items[self._currentSelectedName].Icon else "rbxassetid://125352837907619"
end

local function fillItems(self: ControllerTemplate.Type)
    local scrollingFrame: ScrollingFrame = self._frame:WaitForChild("ScrollingFrame")
    local itemTemplate: Frame = scrollingFrame:WaitForChild("ItemTemplate")
    local sortedBaskets = self._utils.GetKeys(BasketsConfig.Items)

    table.sort(sortedBaskets, function(basketNameA: string, basketNameB: string)
        return BasketsConfig.Items[basketNameA].PriceInCash < BasketsConfig.Items[basketNameB].PriceInCash
    end)

    for i = 1, #sortedBaskets do
        local itemFrame = itemTemplate:Clone()
        itemFrame.Parent = scrollingFrame
        itemFrame.LayoutOrder = i

        local name = sortedBaskets[i]
        local robuxPrice

        if BasketsConfig.Items[name].ProductId then
            local info = self._utils.TryGetProductInfo(BasketsConfig.Items[name].ProductId, Enum.InfoType.Product)
            robuxPrice = if info then info.PriceInRobux else "???"
            self._robuxPrices[name] = robuxPrice
        end

        self._viewsPerName[name] = BasketButtonView.new(itemFrame, name, self._controllers, self._utils, robuxPrice)

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
    descriptionFrame.ItemName.Text = BasketsConfig.Items[newSelectedItem].PublicName
    descriptionFrame.Capacity.Label.Text = string.format("Capacity: %s", self._utils.FormatNumber(BasketsConfig.Items[newSelectedItem].FoodCapacity))

    if self._robuxPrices[newSelectedItem] then
        descriptionFrame.Cost.Icon.Image = "rbxasset://textures/ui/common/robux@3x.png"
        descriptionFrame.Cost.Label.Text = self._robuxPrices[newSelectedItem]
    else
        descriptionFrame.Cost.Icon.Image = "rbxassetid://80513201967002"
        descriptionFrame.Cost.Label.Text = self._utils.FormatNumber(BasketsConfig.Items[newSelectedItem].PriceInCash)
    end

    updateDescritionView(self)
end

function BaseFrame:AfterPlayerLoaded(player: Player)
    self._currentBasket = player:WaitForChild("Equipment"):WaitForChild("Basket") :: StringValue
    self:UpdateInfoFrame(self._currentBasket.Value)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.Description.ActionButton, function()
        if self._isCurrentItemEquipped then return end

        if self._ownsCurrent then
            self._controllers.InventoryController:TryEquipItem("Baskets", self._currentSelectedName)
        else
            self._controllers.InventoryController:RequestItemUnlocking("Baskets", self._currentSelectedName)
        end
    end)

    self._controllers.InventoryController.Updated:Subscribe(self, function()
        updateDescritionView(self)
    end)

    self._currentBasket.Changed:Connect(function()
        updateDescritionView(self)
    end)
end

function BaseFrame:Initialize()
    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.CloseButton, function()
        self._controllers.GuiController.BasketsGui:Disable()
    end)

    fillItems(self)
end

function BaseFrame.new(frame: Frame)
    local self = setmetatable(BaseFrame, {__index = ControllerTemplate})
    self._robuxPrices = {}
    self._viewsPerName = {}
    self._frame = frame

    return self
end

return BaseFrame