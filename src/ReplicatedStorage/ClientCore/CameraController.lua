local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraConfig = require(ReplicatedStorage.Configs.CameraConfig)
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CameraController = {}

local function createAttachment(root: Part, offset: CFrame) : Attachment
    local attachment = Instance.new("Attachment") :: Attachment
    attachment.Name = "CameraAttachment"
    attachment.Parent = root
    attachment.CFrame = offset

    return attachment
end

function CameraController:TweenTo(target: CFrame, time: number, start: CFrame?) : RBXScriptSignal
    start = start or self._camera:GetPivot()
    self._camera.CameraType = Enum.CameraType.Scriptable
    self._camera:PivotTo(start)

    local tween = TweenService:Create(self._camera, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = target})
    tween:Play()

    return tween.Completed
end

-- function CameraController:StartCameraShake(shakeIntensity: number)
--     if self._isShaking then return end

--     self._isShaking = true
--     local originalCFrame = self._camera.CFrame

--     self._shakingTask = task.spawn(function()
--         while self._isShaking do
--             local offset = Vector3.new(
--                 self._random:NextNumber(-shakeIntensity, shakeIntensity),
--                 self._random:NextNumber(-shakeIntensity, shakeIntensity),
--                 self._random:NextNumber(-shakeIntensity, shakeIntensity)
--             )

--             local currentCFrame = self._camera.CFrame
--             local targetCFrame = currentCFrame + offset

--             local tween = TweenService:Create(self._camera, TweenInfo.new(0.3), {CFrame = targetCFrame})
--             tween:Play()
--             tween.Completed:Wait()
--         end

--         self._camera.CFrame = originalCFrame
--     end)
-- end

function CameraController:StartCameraShake(shakeIntensity: number)
    if self._isShaking then return end

    self._isShaking = true

    print(self._camera.CameraSubject)

    self._shakingTask = task.spawn(function()
        while self._isShaking do
            local offset = Vector3.new(
                self._random:NextNumber(-shakeIntensity, shakeIntensity),
                self._random:NextNumber(-shakeIntensity, shakeIntensity),
                self._random:NextNumber(-shakeIntensity, shakeIntensity)
            )

            self._shakingOffset = CFrame.new(offset)
            task.wait()
        end
    end)
end

function CameraController:StopCameraShake()
    if not self._shakingTask then return end

    task.cancel(self._shakingTask)
    self._shakingTask = nil
    self._isShaking = false
    self._shakingOffset = CFrame.new(Vector3.new(0, 0, 0))
end

function CameraController:ShakeWithoutPivoting(humanoid: Humanoid, shakeIntencity: number, duration: number, frequency: number)
    if self._isShaking then return end

    local originalOffset = humanoid.CameraOffset
    local leftTime = duration
    self._isShaking = true

    task.spawn(function()
        while true do
            local progress = (duration - leftTime) / duration
            local fadeIntensity = shakeIntencity * (1 - progress)

            if progress >= 1 then
                self._isShaking = false

                break
            end

            local offset = Vector3.new(
                self._random:NextNumber(-shakeIntencity, shakeIntencity) * fadeIntensity,
                self._random:NextNumber(-shakeIntencity, shakeIntencity) * fadeIntensity,
                self._random:NextNumber(-shakeIntencity, shakeIntencity) * fadeIntensity
            )

            local tween = TweenService:Create(humanoid, TweenInfo.new(frequency), {CameraOffset = originalOffset + offset})
            leftTime -= frequency
            tween:Play()
            tween.Completed:Wait()
        end

        humanoid.CameraOffset = originalOffset
    end)
end

function CameraController:DoShakeCircle(shakeIntencity: number, duration: number?)
    if self._isShaking then return end

    duration = duration or self._configs.CameraConfig.ShakingCircle.Duration
    local leftTime = duration
    self._isShaking = true

    task.spawn(function()
        while true do
            local progress = (duration - leftTime) / duration
            local fadeIntensity = shakeIntencity * (1 - progress)

            if progress >= 1 then
                self._shakingOffset = CFrame.fromOrientation(0, 0, 0)
                self._isShaking = false

                break
            end

            local angle = math.rad(progress * 360)
            local offsetY = fadeIntensity * math.sin(angle)
            local offsetX = fadeIntensity * math.cos(angle)
            self._shakingOffset = CFrame.fromOrientation(0, math.rad(offsetX), math.rad(offsetY))

            leftTime -= task.wait()
        end
    end)
end

function CameraController:PivotCamera(character: Model, offsetCframe: CFrame)
    self._currentAttachment = createAttachment(character.HumanoidRootPart, offsetCframe)
    self._camera.CameraType = Enum.CameraType.Scriptable

    if self._renderBind then
        RunService:UnbindFromRenderStep(self._renderBind)
        self._renderBind = nil
    end

    self._renderBind = "CameraUpdate"
    self._camera:PivotTo(self._currentAttachment.WorldCFrame * self._shakingOffset)

    RunService:BindToRenderStep(self._renderBind, Enum.RenderPriority.Camera.Value + 1, function()
        self._camera:PivotTo(self._currentAttachment.WorldCFrame * self._shakingOffset)
    end)
end

function CameraController:PivotCameraToPart(part: Part, offsetCframe: CFrame)
    self._currentAttachment = createAttachment(part, offsetCframe)
    self._camera.CameraType = Enum.CameraType.Scriptable

    if self._renderBind then
        RunService:UnbindFromRenderStep(self._renderBind)
        self._renderBind = nil
    end

    self._renderBind = "CameraUpdate"
    self._camera:PivotTo(self._currentAttachment.WorldCFrame * self._shakingOffset)

    RunService:BindToRenderStep(self._renderBind, Enum.RenderPriority.Camera.Value + 1, function()
        self._camera:PivotTo(self._currentAttachment.WorldCFrame * self._shakingOffset)
    end)
end

function CameraController:FreezeCamera(character: Model)
    local cameraFrame = self._camera:GetPivot()
    local offset = character:GetPivot():ToObjectSpace(cameraFrame)
    self:PivotCamera(character, offset)
end

function CameraController:FixThirdPerson(character: Model)
    self:PivotCamera(character, CameraConfig.ThirdPersonOffset)
end

function CameraController:WatchTarget(target)
	self._camera.CameraType = Enum.CameraType.Track
	self._camera.CameraSubject = target
end

function CameraController:ResetCamera()
    if self._currentAttachment then
        self._currentAttachment:Destroy()
    end

    if self._renderBind then
        RunService:UnbindFromRenderStep(self._renderBind)
        self._renderBind = nil
    end

    local character = self._player.Character or self._player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

    self._camera.CameraType = Enum.CameraType.Custom
	self._camera.CameraSubject = humanoid
end

function CameraController:Initialize(player: Player)
    self._player = player
    self._random = Random.new(os.time())
    self._camera = workspace.CurrentCamera
    self._shakingOffset = CFrame.fromOrientation(0, 0, 0)
    self._shakingTask = nil
end

function CameraController.new()
    return setmetatable(CameraController, {__index = ControllerTemplate})
end

return CameraController