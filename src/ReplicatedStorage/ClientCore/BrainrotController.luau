local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Brainrots
local CountdownOver = Remotes.CountdownOver :: RemoteEvent
local StartJumpPreparation = Remotes.StartJumpPreparation :: RemoteFunction
local JumpEnded = Remotes.JumpEnded :: RemoteEvent

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local RunService = game:GetService("RunService")

local BrainrotController = {}

function BrainrotController:StartJump()
    local zone = self._controllers.ZoneController:GetZone()
    local currentModel = zone.BrainrotPoint:FindFirstChildOfClass("Model")
    local cameraPoint = currentModel:FindFirstChild("CameraPoint")

    if not StartJumpPreparation:InvokeServer() then return end

    self._controllers.CameraController:TweenTo(cameraPoint.CFrame, 3)

    local timeLeft = 3

    self.CountdownStarted:Invoke()

    while task.wait(1) do
        -- show time left on screen
        timeLeft -= 1

        if timeLeft < 0 then break end
    end

    CountdownOver:FireServer()

    self._controllers.CameraController:ResetCamera()
    self._controllers.CameraController:WatchTarget(currentModel.GuiPart)

    self.JumpStarted:Invoke()
    -- start showing cash and altitude in the HUD

    -- reset camera again in the end
end

function BrainrotController:AfterPlayerLoaded(player: Player)
    self._player = player
end

function BrainrotController:Initialize()
    self._inDebounce = false

    JumpEnded.OnClientEvent:Connect(function()
        self._controllers.CameraController:ResetCamera()
    end)
end

function BrainrotController:InjectUtils(utils)
    self._utils = utils
    self.CountdownStarted = utils.Event.new()
    self.JumpStarted = utils.Event.new()
end

function BrainrotController.new()
    return setmetatable(BrainrotController, {__index = ControllerTemplate})
end

return BrainrotController