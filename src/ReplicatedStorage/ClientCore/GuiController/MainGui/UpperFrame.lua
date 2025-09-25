local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local UpperFrame = {} :: ControllerTemplate.Type

function UpperFrame:AfterPlayerLoaded(player: Player)
    
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

    return self
end

return UpperFrame