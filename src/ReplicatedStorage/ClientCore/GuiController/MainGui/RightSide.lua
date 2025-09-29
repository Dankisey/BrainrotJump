local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InfoPin = require(ReplicatedStorage.Modules.UI.InfoPin)

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local RightSide = {} :: ControllerTemplate.Type

function RightSide:Initialize(player: Player)
    local buttons = self._frame.Buttons

    self._controllers.ButtonsInteractionsConnector:ConnectButton(buttons.DailyButton, function()
        self._controllers.GuiController.DailyRewardsGui:Enable(true)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(buttons.ShopButton, function()
        self._controllers.GuiController.RobuxShopGui:Enable(true)
    end)

    self.TimeRewardsButton = buttons.TimeRewardsButton
    self.TimeRewardsPin = InfoPin.new(self.TimeRewardsButton.Icon.Pin)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self.TimeRewardsButton, function()
        self._controllers.GuiController.TimeRewardsGui:Enable(true)
        self.TimeRewardsPin:TurnOff()
    end)

    self.AchievementsButton = buttons.AchievementsButton
    self.AchievementsPin = InfoPin.new(self.AchievementsButton.Icon.Pin)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self.AchievementsButton, function()
        self._controllers.GuiController.AchievementsGui:Enable(true)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(buttons.PotionsButton, function()
        self._controllers.GuiController.PotionsGui:Enable(true)
    end)
end

function RightSide.new(frame: Frame)
    local self = setmetatable(RightSide, {__index = ControllerTemplate})
    self._frame = frame

    return self
end

return RightSide