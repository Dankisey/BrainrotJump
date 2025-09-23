local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SacksConfig = require(ReplicatedStorage.Configs.SacksConfig)
local ClientTypes = require(ReplicatedStorage.Modules.ClientTypes)
local UtilsTypes = require(ReplicatedStorage.Modules.UtilsTypes)

local LocalPlayer = game:GetService("Players").LocalPlayer
local CurrentSack = LocalPlayer:WaitForChild("Equipment"):WaitForChild("Sack") :: StringValue

export type SackButtonView = {
    new: (itemFrame: Frame, name: string, controllers: ClientTypes.Controllers, utils: UtilsTypes.Utils) -> SackButtonView;
    Unselect: (SackButtonView) -> nil;
    Select: (SackButtonView) -> nil;

    _controllers: ClientTypes.Controllers;
    _utils: UtilsTypes.Utils;
    _isEquipped: boolean;
    _isOwned: boolean;
    _frame: Frame;
    _name: string;
}

local SackButtonView = {} :: SackButtonView

local function updateView(self: SackButtonView)
	self._frame.Button.Icon.Image = if self._isOwned then SacksConfig.Items[self._name].Icon else "rbxassetid://11662997125"

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

local function initialize(self: SackButtonView)
    if self._robuxPrice then
        self._frame.Button.Cost.Icon.Image = "rbxasset://textures/ui/common/robux@3x.png"
        self._frame.Button.Cost.Label.Text = self._robuxPrice
    else
		self._frame.Button.Cost.Icon.Image = "rbxassetid://18885492705"
        self._frame.Button.Cost.Label.Text = self._utils.FormatNumber(SacksConfig.Items[self._name].PriceInCash)
    end

    self._frame.Button.UIGradient.Color = SacksConfig.Items[self._name].Rarity.Gradient
    self._frame.Button.NameLabel.Text = SacksConfig.Items[self._name].PublicName
    self._frame.Button.Icon.Image = SacksConfig.Items[self._name].Icon

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.Button, function()
        self._controllers.GuiController.SacksGui.BaseFrame:UpdateInfoFrame(self._name)
    end)

    self._isOwned = self._controllers.InventoryController:HasEquipment("Sacks", self._name)
    self._isEquipped = CurrentSack.Value == self._name

    CurrentSack.Changed:Connect(function()
        self._isEquipped = CurrentSack.Value == self._name
        updateView(self)
    end)

    self._controllers.InventoryController.Updated:Subscribe(self, function()
        self._isOwned = self._controllers.InventoryController:HasEquipment("Sacks", self._name)
        updateView(self)
    end)

    updateView(self)
end

function SackButtonView:Unselect()
    self._frame.Button.UIStroke.Color = Color3.fromRGB(255, 255, 255)
end

function SackButtonView:Select()
    self._frame.Button.UIStroke.Color = Color3.fromRGB(0, 0, 0)
end

function SackButtonView.new(itemFrame: Frame, name: string, controllers: ClientTypes.Controllers, utils: UtilsTypes.Utils, robuxPrice) : SackButtonView
    local self = setmetatable({}, {__index = SackButtonView})
    self._controllers = controllers
    self._robuxPrice = robuxPrice
    self._utils = utils
    self._frame = itemFrame
    self._name = name
    self._isEquipped = false
    self._isOwned = false
    initialize(self)

    return self
end

return SackButtonView