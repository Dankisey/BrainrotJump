local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Brainrots
local StopRequested = Remotes.StopRequested :: RemoteEvent
local JumpEnded = Remotes.JumpEnded :: RemoteEvent

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local JumpFrame = {} :: ControllerTemplate.Type

function JumpFrame:StartCountdown()
    self._countdownFrame.Visible = true
    local timeLeft = 3

    while task.wait(1) do
        local label = self._countdownFrame:FindFirstChild(timeLeft)

        if not label then return end

        label.Visible = true

        task.spawn(function()
            -- tween label
            task.wait(1)
            label.Visible = false
        end)

        timeLeft -= 1

        if timeLeft < 0 then break end
    end

    self._countdownFrame.Visible = false
end

function JumpFrame:StartJump()
    self._inJumpFrame.Visible = true

    -- constantly update height
    -- update cash only if value is higher than prev
end

function JumpFrame:AfterPlayerLoaded()

end

function JumpFrame:Initialize()
    self._countdownFrame = self._frame.CountdownFrame
    self._inJumpFrame = self._frame.InJumpFrame

    self._controllers.BrainrotController.CountdownStarted:Subscribe(self, function()
        self:StartCountdown()
    end)

    self._controllers.BrainrotController.JumpStarted:Subscribe(self, function()
        self:StartJump()
    end)

    JumpEnded.OnClientEvent:Connect(function()
        self._inJumpFrame.Visible = false
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._inJumpFrame.StopJumpButton, function()
        StopRequested:FireServer()
    end)
end

function JumpFrame.new(frame: Frame)
    local self = setmetatable(JumpFrame, {__index = ControllerTemplate})
    self._frame = frame

    return self
end

return JumpFrame