local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientTypes = require(ReplicatedStorage.Modules.ClientTypes)
local UtilsTypes = require(ReplicatedStorage.Modules.UtilsTypes)

export type WorldPlate = {
    new: (palte: Frame, data: {any}, controllers: ClientTypes.Controllers, utils: UtilsTypes.Utils) -> WorldPlate;

    _controllers: ClientTypes.Controllers;
    _utils: UtilsTypes.Utils;
    _frame: Frame;
    _data: {any};
}

local WorldPlate = {} :: WorldPlate

local function update(self: WorldPlate)
    local currentWorld = self._controllers.WorldsController:GetCurrentWorldIndex()
    local isUnlocked = self._controllers.WorldsController:IsWorldUnlocked()

    if currentWorld == self._data.Index then
        self._unlockButton.Visible = false
        self._goButton.Visible = false
    elseif isUnlocked then
        self._unlockButton.Visible = false
        self._goButton.Visible = true
    else
        self._unlockButton.Visible = true
        self._goButton.Visible = false
    end
end

local function initialize(self: WorldPlate)
    local mainPlate = self._frame.WorldPlate :: Frame
    mainPlate.NameLabel.Text = self._data.PublicName
    self._unlockButton = mainPlate.UnlockButton
    self._unlockButton.CostLabel.Text = self._utils.FormatNumber(self._data.PriceInWins)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._unlockButton, function()
        self._controllers.WorldsController:RequestWorldUnlock(self._data.Index)
    end)

    self._goButton = mainPlate.GoButton

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._goButton, function()
        self._controllers.WorldsController:RequestWorldChange(self._data.Index)
    end)

    self._controllers.WorldsController.WorldChanged:Subscribe(self, function()
        update(self)
    end)

    self._controllers.WorldsController.Updated:Subscribe(self, function()
        update(self)
    end)

    update(self)
end

function WorldPlate.new(palte: Frame, data: {any}, controllers: ClientTypes.Controllers, utils: UtilsTypes.Utils) : WorldPlate
    local self = setmetatable({}, {__index = WorldPlate})
    self._controllers = controllers
    self._utils = utils
    self._frame = palte
    self._data = data
    initialize(self)

    return self
end

return WorldPlate