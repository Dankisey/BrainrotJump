local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Brainrots
local StartJumpPreparation = Remotes.StartJumpPreparation :: RemoteFunction
local CheckpointPassed = Remotes.CheckpointPassed :: RemoteEvent
local CountdownOver = Remotes.CountdownOver :: RemoteEvent
local BrainrotFed = Remotes.BrainrotFed :: RemoteEvent
local JumpEnded = Remotes.JumpEnded :: RemoteEvent

local Skyboxes = ReplicatedStorage.Assets.Skyboxes
local Lighting = game:GetService("Lighting")

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local RunService = game:GetService("RunService")

local BrainrotController = {}

local function changeSkybox(self, currentCheckpoint: number)
    self._currentSkybox:Destroy()
    local skybox = Skyboxes:WaitForChild(currentCheckpoint):Clone()
    skybox.Parent = Lighting
    self._currentSkybox = skybox
end

function BrainrotController:StartJump()
    local zone = self._controllers.ZoneController:GetZone()
    local currentModel = zone.BrainrotPoint:FindFirstChildOfClass("Model")
    local cameraPoint = currentModel:FindFirstChild("CameraPoint")

    if not StartJumpPreparation:InvokeServer() then return end

    self._controllers.CameraController:TweenTo(cameraPoint.CFrame, 3)

    local timeLeft = 3

    self.CountdownStarted:Invoke()

    while task.wait(1) do
        timeLeft -= 1

        if timeLeft < 0 then break end
    end

    CountdownOver:FireServer()

    self._controllers.CameraController:ResetCamera()
    self._controllers.CameraController:WatchTarget(currentModel.GuiPart)

    -- self._controllers.CameraController:PivotCameraToPart(currentModel.GuiPart, CFrame.new(Vector3.zAxis * 10))

    -- ADD CAMERA SHAKE
    --self._controllers.CameraController:StartCameraShake(.2)

    self.JumpStarted:Invoke(currentModel)
end

function BrainrotController:AfterPlayerLoaded(player: Player)
    self._player = player
end

function BrainrotController:Initialize()
    self._inDebounce = false
    self._currentSkybox = Lighting:WaitForChild("Sky")

    JumpEnded.OnClientEvent:Connect(function()
        self._controllers.CameraController:StopCameraShake()
        self._controllers.SoundPlayer:PlaySound(self._configs.SoundNames.Impact)

        task.delay(1, function()
            self._controllers.CameraController:ResetCamera()
        end)
    end)

    CheckpointPassed.OnClientEvent:Connect(function(currentCheckpoint: number)
        changeSkybox(self, currentCheckpoint)
    end)

    BrainrotFed.OnClientEvent:Connect(function()
        self._controllers.SoundPlayer:PlaySound(self._configs.SoundNames.Eating)
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