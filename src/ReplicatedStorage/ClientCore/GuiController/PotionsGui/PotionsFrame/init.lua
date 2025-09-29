local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local PotionsFrame = {}

function PotionsFrame:Initialize()
    local closeButton = self._frame.CloseButton :: GuiButton

    self._controllers.ButtonsInteractionsConnector:ConnectButton(closeButton, function()
        self._controllers.GuiController.PotionsGui:Disable()
    end)

    self._conumables = require(script.Consumables).new(self._frame.Consumables, self._controllers, self._utils)
    self._conumables:Initialize()
end

function PotionsFrame.new(frame: Frame)
	local self = setmetatable(PotionsFrame, {__index = ControllerTemplate})
    self._frame = frame

	return self
end

return PotionsFrame