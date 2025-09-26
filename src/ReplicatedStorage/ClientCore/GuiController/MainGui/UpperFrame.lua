local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Counter = require(ReplicatedStorage.Modules.UI.Counter)

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local UpperFrame = {} :: ControllerTemplate.Type

function UpperFrame:AfterPlayerLoaded(player: Player)
    local currenciesDisplay = self._frame.CurrenciesDisplay

    local cash = player:WaitForChild("Currencies"):WaitForChild("Cash") :: IntValue
	self.Counters.Cash = Counter.new(currenciesDisplay.Cash, cash)

    local wins = player:WaitForChild("Currencies"):WaitForChild("Wins") :: IntValue
	self.Counters.Wins = Counter.new(currenciesDisplay.Wins, wins)
end

function UpperFrame:Initialize()
    self.SpinButton = self._frame.SpinButton

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self.SpinButton, function()
        self._controllers.GuiController.SpinGui:Enable(true)
    end)
end

function UpperFrame.new(frame: Frame)
    local self = setmetatable(UpperFrame, {__index = ControllerTemplate})
    self._frame = frame
    self.Counters = {}

    return self
end

return UpperFrame