local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BasketsConfig = require(ReplicatedStorage.Configs.BasketsConfig)
local ClientTypes = require(ReplicatedStorage.Modules.ClientTypes)
local UtilsTypes = require(ReplicatedStorage.Modules.UtilsTypes)

local LocalPlayer = game:GetService("Players").LocalPlayer
local CurrentBasket = LocalPlayer:WaitForChild("Equipment"):WaitForChild("Basket") :: StringValue

export type BasketButtonView = {
    new: (itemFrame: Frame, name: string, controllers: ClientTypes.Controllers, utils: UtilsTypes.Utils) -> BasketButtonView;
    Unselect: (BasketButtonView) -> nil;
    Select: (BasketButtonView) -> nil;

    _controllers: ClientTypes.Controllers;
    _utils: UtilsTypes.Utils;
    _isEquipped: boolean;
    _isOwned: boolean;
    _frame: Frame;
    _name: string;
}

local BasketButtonView = {} :: BasketButtonView

local function updateView(self: BasketButtonView)
    self._frame.Button.Icon.Image = if self._isOwned then BasketsConfig.Items[self._name].Icon else "rbxassetid://125352837907619"

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

local function initialize(self: BasketButtonView)
    if self._robuxPrice then
        self._frame.Button.Cost.Icon.Image = "rbxasset://textures/ui/common/robux@3x.png"
        self._frame.Button.Cost.Label.Text = self._robuxPrice
    else
        self._frame.Button.Cost.Icon.Image = "rbxassetid://80513201967002"
        self._frame.Button.Cost.Label.Text = self._utils.FormatNumber(BasketsConfig.Items[self._name].PriceInCash)
    end

    self._frame.Button.UIGradient.Color = BasketsConfig.Items[self._name].Rarity.Gradient
    self._frame.Button.NameLabel.Text = BasketsConfig.Items[self._name].PublicName
    self._frame.Button.Icon.Image = BasketsConfig.Items[self._name].Icon

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.Button, function()
        self._controllers.GuiController.BasketsGui.BaseFrame:UpdateInfoFrame(self._name)
    end)

    self._isOwned = self._controllers.InventoryController:HasEquipment("Baskets", self._name)
    self._isEquipped = CurrentBasket.Value == self._name

    CurrentBasket.Changed:Connect(function()
        self._isEquipped = CurrentBasket.Value == self._name
        updateView(self)
    end)

    self._controllers.InventoryController.Updated:Subscribe(self, function()
        self._isOwned = self._controllers.InventoryController:HasEquipment("Baskets", self._name)
        updateView(self)
    end)

    updateView(self)
end

function BasketButtonView:Unselect()
    self._frame.Button.UIStroke.Color = Color3.fromRGB(255, 255, 255)
end

function BasketButtonView:Select()
    self._frame.Button.UIStroke.Color = Color3.fromRGB(0, 0, 0)
end

function BasketButtonView.new(itemFrame: Frame, name: string, controllers: ClientTypes.Controllers, utils: UtilsTypes.Utils, robuxPrice) : BasketButtonView
    local self = setmetatable({}, {__index = BasketButtonView})
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

return BasketButtonView