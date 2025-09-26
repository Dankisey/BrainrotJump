local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TrailsConfig = require(ReplicatedStorage.Configs.TrailsConfig)
local ClientTypes = require(ReplicatedStorage.Modules.ClientTypes)
local UtilsTypes = require(ReplicatedStorage.Modules.UtilsTypes)
local TrailAssets = ReplicatedStorage.Assets.Trails

local LocalPlayer = game:GetService("Players").LocalPlayer
local CurrentTrail = LocalPlayer:WaitForChild("Equipment"):WaitForChild("Trail") :: StringValue

export type TrailButtonView = {
    new: (itemFrame: Frame, name: string, controllers: ClientTypes.Controllers, utils: UtilsTypes.Utils) -> TrailButtonView;
    Unselect: (TrailButtonView) -> nil;
    Select: (TrailButtonView) -> nil;

    _controllers: ClientTypes.Controllers;
    _utils: UtilsTypes.Utils;
    _isEquipped: boolean;
    _isOwned: boolean;
    _frame: Frame;
    _name: string;
}

local TrailButtonView = {} :: TrailButtonView

local function updateView(self: TrailButtonView)
    if self._isEquipped then
        self._frame.Button.StatusLabel.Text = "Equipped"
        self._frame.Button.StatusLabel.Visible = true
        self._frame.Button.Cost.Visible = false
    elseif self._isOwned then
        self._frame.Button.StatusLabel.Text = "Owned"
        self._frame.Button.StatusLabel.Visible = true
        self._frame.Button.Cost.Visible = false
    else
        self._frame.Button.Cost.Visible = true
        self._frame.Button.StatusLabel.Visible = false
    end
end

local function initialize(self: TrailButtonView)
    self._frame.Button.Cost.Label.Text = self._utils.FormatNumber(TrailsConfig[self._name].Cost)
    self._frame.Button.Icon.UIGradient.Color = TrailAssets[self._name].Color
    self._frame.Button.NameLabel.Text = self._name

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.Button, function()
        self._controllers.GuiController.TrailsGui.BaseFrame:UpdateInfoFrame(self._name)
    end)

    self._isOwned = self._controllers.InventoryController:HasEquipment("Trails", self._name)
    self._isEquipped = CurrentTrail.Value == self._name

    CurrentTrail.Changed:Connect(function()
        self._isEquipped = CurrentTrail.Value == self._name
        updateView(self)
    end)

    self._controllers.InventoryController.Updated:Subscribe(self, function()
        self._isOwned = self._controllers.InventoryController:HasEquipment("Trails", self._name)
        updateView(self)
    end)

    updateView(self)
end

function TrailButtonView:Unselect()
    self._frame.Button.UIStroke.Color = Color3.fromRGB(255, 255, 255)
end

function TrailButtonView:Select()
    self._frame.Button.UIStroke.Color = Color3.fromRGB(0, 0, 0)
end

function TrailButtonView.new(itemFrame: Frame, name: string, controllers: ClientTypes.Controllers, utils: UtilsTypes.Utils) : TrailButtonView
    local self = setmetatable({}, {__index = TrailButtonView})
    self._controllers = controllers
    self._utils = utils
    self._frame = itemFrame
    self._name = name
    self._isEquipped = false
    self._isOwned = false
    initialize(self)

    return self
end

return TrailButtonView