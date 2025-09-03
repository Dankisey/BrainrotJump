local FormatNumber = require(game.ReplicatedStorage.Modules.Utils.FormatNumber)

local Counter = {}

function Counter:Update()
	self._label.Text = FormatNumber(self._currencyValueObject.Value)
end

function Counter.new(frame: Frame, intValue: IntValue)
    local self = setmetatable({}, {__index = Counter})
    self._currencyValueObject = intValue.Value
    self._label = frame.CounterLabel
    self:Update()

    return self
end

return Counter