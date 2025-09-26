local BaseSpeed = game:GetService("StarterPlayer").CharacterWalkSpeed
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TrailAssets = ReplicatedStorage.Assets.Trails
local TrailsConfig = require(ReplicatedStorage.Configs.TrailsConfig)
local TrailButtonView = require(script.TrailButtonView)

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local BaseFrame = {} :: ControllerTemplate.Type

local function updateDescritionView(self: ControllerTemplate.Type)
    local descriptionFrame = self._frame.Description
    local actionButtonLabel = descriptionFrame.ActionButton.Label

    if self._currentSelectedName == self._currentTrail.Value then
        actionButtonLabel.Text = "Equipped"
        self._isCurrentItemEquipped = true
        self._ownsCurrent = true
    elseif self._controllers.InventoryController:HasEquipment("Trails", self._currentSelectedName) then
        actionButtonLabel.Text = "Equip"
        self._isCurrentItemEquipped = false
        self._ownsCurrent = true
    else
        actionButtonLabel.Text = "Buy"
        self._isCurrentItemEquipped = false
        self._ownsCurrent = false
    end

	descriptionFrame.Icon.UIGradient.Color = TrailAssets[self._currentSelectedName].Color
end

local function fillItems(self: ControllerTemplate.Type)
    local scrollingFrame: ScrollingFrame = self._frame:WaitForChild("ScrollingFrame")
    local itemTemplate: Frame = scrollingFrame:WaitForChild("ItemTemplate")
    local sortedTrails = self._utils.GetKeys(TrailsConfig)

    table.sort(sortedTrails, function(trailNameA: string, trailNameB: string)
        return TrailsConfig[trailNameA].Cost < TrailsConfig[trailNameB].Cost
    end)

    for i = 1, #sortedTrails do
        local itemFrame = itemTemplate:Clone()
        itemFrame.Parent = scrollingFrame
        itemFrame.LayoutOrder = i

        local name = sortedTrails[i]
        self._viewsPerName[name] = TrailButtonView.new(itemFrame, name, self._controllers, self._utils)
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
    descriptionFrame.ItemName.Text = newSelectedItem
    local bonus = math.floor((TrailsConfig[newSelectedItem].SpeedBonus / BaseSpeed) * 10) / 10
    descriptionFrame.MultiplierSpeed.Label.Text = ("X%.1f"):format(1 + bonus)
    descriptionFrame.MultiplierCash.Label.Text = ("X%.1f"):format(TrailsConfig[newSelectedItem].CashMultiplier)
    descriptionFrame.Cost.Label.Text = self._utils.FormatNumber(TrailsConfig[newSelectedItem].Cost)

    updateDescritionView(self)
end

function BaseFrame:AfterPlayerLoaded(player: Player)
    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.CloseButton, function()
        self._controllers.GuiController.TrailsGui:Disable()
    end)

    fillItems(self)

    self._currentTrail = player:WaitForChild("Equipment"):WaitForChild("Trail") :: StringValue
    self:UpdateInfoFrame(self._currentTrail.Value)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.Description.ActionButton, function()
        if self._isCurrentItemEquipped then return end

        if self._ownsCurrent then
            self._controllers.InventoryController:TryEquipItem("Trails", self._currentSelectedName)
        else
            self._controllers.InventoryController:RequestItemUnlocking("Trails", self._currentSelectedName)
        end
    end)

    self._controllers.InventoryController.Updated:Subscribe(self, function()
        updateDescritionView(self)
    end)

    self._currentTrail.Changed:Connect(function()
        updateDescritionView(self)
    end)
end

function BaseFrame.new(frame: Frame)
    local self = setmetatable(BaseFrame, {__index = ControllerTemplate})
    self._viewsPerName = {}
    self._frame = frame

    return self
end

return BaseFrame