local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BrainrotConfig = require(ReplicatedStorage.Configs.BrainrotConfig)
local Particles = ReplicatedStorage.Assets:WaitForChild("Particles"):WaitForChild("SpeedLines")

local Remotes = ReplicatedStorage.Remotes.Brainrots
local StartJumpPreparation = Remotes.StartJumpPreparation :: RemoteFunction
local CheckpointPassed = Remotes.CheckpointPassed :: RemoteEvent
local CountdownOver = Remotes.CountdownOver :: RemoteEvent
local BrainrotFed = Remotes.BrainrotFed :: RemoteEvent
local JumpEnded = Remotes.JumpEnded :: RemoteEvent

local Skyboxes = ReplicatedStorage.Assets.Skyboxes
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

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

    self._controllers.CameraController:TweenTo(cameraPoint.CFrame, .5)
    task.wait(.5)
    self._controllers.CameraController:PivotCameraToPart(cameraPoint, CFrame.new())

    self.CountdownStarted:Invoke()

    self._controllers.CameraController:StartCameraShake(BrainrotConfig.JumpEffectParameters.PreJumpMinIntensity)
    self._controllers.CameraController:ChangeShakeIntensity(BrainrotConfig.JumpEffectParameters.PreJumpMinIntensity, BrainrotConfig.JumpEffectParameters.PreJumpMaxIntensity, 1.5, .3)

    task.wait(1.5)

    self._controllers.CameraController:StopCameraShake()
    CountdownOver:FireServer()
    self._controllers.CameraController:ResetCamera()
    self._controllers.CameraController:WatchTarget(currentModel.GuiPart)

    local Camera = workspace.CurrentCamera
    self._runConnection = RunService.RenderStepped:Connect(function()
        if (not self._character) then return end

        if not self._currentParticles then
            self._currentParticles = Particles:Clone()
            self._currentParticles.Parent = game.Workspace
            self._currentParticles.CFrame = Camera.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))
        else
            self._currentParticles.CFrame = Camera.CFrame * CFrame.new(0, 0, -5) * CFrame.Angles(math.rad(-90), math.rad(0), math.rad(0))
        end
    end)

    -- self._controllers.CameraController:PivotCameraToPart(currentModel.GuiPart, CFrame.new(Vector3.zAxis * 10))

    -- ADD CAMERA SHAKE
    --self._controllers.CameraController:StartCameraShake(.2)

    self.JumpStarted:Invoke(currentModel)
end

function BrainrotController:ToggleAutoJump()
    self.IsInAutoJump = not self.IsInAutoJump

    if self.IsInAutoJump then
        task.spawn(function()
            self:StartJump()
        end)
    end
end

function BrainrotController:AfterPlayerLoaded(player: Player)
    self._player = player
end

function BrainrotController:Initialize()
    self._inDebounce = false
    self._currentSkybox = Lighting:WaitForChild("Sky")
    self.IsInAutoJump = false

    JumpEnded.OnClientEvent:Connect(function()
        local zone = self._controllers.ZoneController:GetZone()
        local currentModel = zone.BrainrotPoint:FindFirstChildOfClass("Model")
        local cameraPoint = currentModel:FindFirstChild("CameraPoint")
        self._controllers.CameraController:PivotCameraToPart(cameraPoint, CFrame.new())
        self._controllers.CameraController:StartCameraShake(BrainrotConfig.JumpEffectParameters.PostJumpShakeIntensity)
        task.wait(BrainrotConfig.JumpEffectParameters.PostJumpShakeDuration)
        self._controllers.CameraController:StopCameraShake()
        self._controllers.SoundPlayer:PlaySound(self._configs.SoundNames.Impact)

        if self._currentParticles then
            self._currentParticles:Destroy()
            self._currentParticles = nil
        end

        if self._runConnection then
            self._runConnection:Disconnect()
            self._runConnection = nil
        end

        task.delay(1, function()
            self._controllers.CameraController:ResetCamera()

            if self.IsInAutoJump then
                task.wait(4)

                if not self.IsInAutoJump then return end

                self:StartJump()
            end
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