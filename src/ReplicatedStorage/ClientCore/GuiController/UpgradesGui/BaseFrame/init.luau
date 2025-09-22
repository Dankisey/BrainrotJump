local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local UpgradesConfig = require(ReplicatedStorage.Configs.UpgradesConfig)
local UpgradeHolder = require(script.UpgradeHolder)

export type UpgradesFrame = {
    _upgradeHolders: {[string]: UpgradeHolder.Type};
    _pointsValueObject: IntValue;
    _pointsLabel: TextLabel;
    _frame: Frame;
} & ControllerTemplate.Type

local BaseFrame = {}

local function updatePointsLabel(self: UpgradesFrame)
    self._pointsLabel.Text = string.format("Upgrade Points: %d", self._pointsValueObject.Value)
end

function BaseFrame:AfterPlayerLoaded(player: Player)
    local scrollingFrame = self._frame.ScrollingFrame :: ScrollingFrame
    local template = scrollingFrame.Holder

    for name, upgradeInfo in pairs(UpgradesConfig.Upgrades) do
        local levelValueObject = player:WaitForChild("Upgrades"):WaitForChild(upgradeInfo.LevelObjectName)
        local holderFrame = template:Clone()
        holderFrame.Parent = scrollingFrame
        holderFrame.Name = name

        self._upgradeHolders[name] = UpgradeHolder.new(holderFrame, levelValueObject, name, self._controllers, self._utils)

        holderFrame.Visible = true
    end

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.CloseButton, function()
        self._controllers.GuiController.UpgradesGui:Disable()
    end)

    self._pointsValueObject = player:WaitForChild("Currencies"):WaitForChild("UpgradePoints")
    self._pointsLabel = self._frame.UpgradePointsLabel
    updatePointsLabel(self)

    self._pointsValueObject.Changed:Connect(function()
        updatePointsLabel(self)
    end)
end

function BaseFrame.new(frame: Frame)
    local self = setmetatable(BaseFrame, {__index = ControllerTemplate})
    self._upgradeHolders = {}
    self._frame = frame

    return self
end

return BaseFrame