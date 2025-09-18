local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local UpgradesConfig = require(ReplicatedStorage.Configs.UpgradesConfig)

local Remotes = ReplicatedStorage.Remotes.Upgrades
local PurchaseAttempted = Remotes.PurchaseAttempted

export type Type = {
    _purchaseButton: GuiButton;
    _levelLabel: TextLabel;
    _lockedFrame: Frame;
    _maxFrame: Frame;

    _levelValue: IntValue;
    _frame: Frame;
    _name: string;

} & ControllerTemplate.Type;

local UpgradeHolder = {} :: Type

local function update(self: Type)
    self._levelLabel.Text = "Level " .. self._levelValue.Value

    if #self._config.Levels > self._levelValue.Value then
        if (not self._config.Levels[self._levelValue.Value + 1].WorldLock) or
            (self._controllers.WorldsController:IsWorldUnlocked(self._config.Levels[self._levelValue.Value + 1].WorldLock)) then

            self._purchaseButton.Visible = true
            self._lockedFrame.Visible = false
            self._maxFrame.Visible = false
        else
            self._purchaseButton.Visible = false
            self._maxFrame.Visible = false

            self._lockedFrame.Label.Text = "World " .. self._config.Levels[self._levelValue.Value + 1].WorldLock
            self._lockedFrame.Visible = true
        end
    else
        self._purchaseButton.Visible = false
        self._lockedFrame.Visible = false
        self._maxFrame.Visible = true
    end
end

local function initialize(self: Type)
    self._config = UpgradesConfig.Upgrades[self._name]
    self._levelLabel = self._frame.Background.LevelLabel
    self._purchaseButton = self._frame.Background.PurchaseButton
    self._lockedFrame = self._frame.Background.LockedFrame
    self._maxFrame = self._frame.Background.MaxFrame

    self._frame.Background.NameLabel.Text = self._config.PublicName
    self._frame.Background.UpgradeIcon.Image = self._config.Icon

    self._controllers.WorldsController.Updated:Subscribe(self, function()
        update(self)
    end)

    self._levelValue.Changed:Connect(function()
        update(self)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._purchaseButton, function()
        PurchaseAttempted:FireServer(self._name)
    end)

    update(self)
end

function UpgradeHolder.new(frame: Frame, levelValue: IntValue, name: string, controllers, utils)
    local self = setmetatable({}, {__index = UpgradeHolder})
    self._controllers = controllers
    self._levelValue = levelValue
    self._frame = frame
    self._utils = utils
    self._name = name
    initialize(self)

    return self
end

return UpgradeHolder