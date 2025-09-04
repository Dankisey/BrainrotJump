local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local EggConfig = require(ReplicatedStorage.Configs.EggConfig)
local EggOpened = ReplicatedStorage.Remotes.Eggs.EggOpened
local Config = require(ReplicatedStorage.Configs.EggHatchingConfig)
local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)
local Assets = ReplicatedStorage.Assets.EggsHatching

local HatchingController = {}

function HatchingController:AfterPlayerLoaded(player: Player)
    self._player = player
    self._gui = player.PlayerGui:WaitForChild("HatchingGui")
end

local function preparePet(model)
    for _,v in pairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
            v.CanQuery = false
            v.CanTouch = false
            v.Anchored = true
            if v:IsA("MeshPart") then
                v.CastShadow = false
            end
        end
    end
end

function HatchingController:StartEggHatchingSequence(eggID : string, pets)
	self._controllers.GuiController.MainGui:Disable()

    for i = 1, #pets do
        task.spawn(function()
            local eggTemplate = ReplicatedStorage.Assets.Eggs[eggID]

			if not eggTemplate then
				warn("Egg template was not found for ID:", eggID)

				return
			end

			local petTemplate = ReplicatedStorage.Assets.Pets[pets[i]]

			if not petTemplate then
				warn("Pet template was not found for ID:", pets[i])

				return
			end

            local egg = eggTemplate:Clone()
            egg.Name = tostring(i)
            preparePet(egg)
            egg.Parent = workspace.Debris

            local posOffset = Instance.new('Vector3Value')
            posOffset.Name = 'posOffset'
            posOffset.Value = Vector3.new(0, -10, -1)
            posOffset.Parent = egg

            local ortOffset = Instance.new('Vector3Value')
            ortOffset.Name = 'ortOffset'
            ortOffset.Parent = egg

            table.insert(self._animatingObjects, egg)

            local appearTween = TweenService:Create(posOffset, TweenInfo.new(0.3), {Value = Vector3.new(0, 0, 0)})
            appearTween:Play()
            appearTween.Completed:Wait()

            for j = 1, #Config.Rotations do
                local rotateTween = TweenService:Create(ortOffset, TweenInfo.new(0.1), {Value = Config.Rotations[j]})
                rotateTween:Play()
                task.wait(0.15)
            end

            local moveBackTween = TweenService:Create(posOffset, TweenInfo.new(0.5), {Value = Vector3.new(0, 0, -2)})
            moveBackTween:Play()
            task.wait(0.25)
            egg:Destroy()

            local pet = petTemplate:Clone()
            pet.Name = tostring(i)
            preparePet(pet)
            pet.Parent = workspace.Debris

            local petPosOffset = Instance.new('Vector3Value')
            petPosOffset.Name = 'posOffset'
            petPosOffset.Value = Vector3.new(0, 0, -2)
            petPosOffset.Parent = pet

            local petOrtOffset = Instance.new('Vector3Value')
            petOrtOffset.Name = 'ortOffset'
            petOrtOffset.Value = Vector3.new(0, 180, 0)
            petOrtOffset.Parent = pet

            table.insert(self._animatingObjects, pet)

            local frame = Assets.Frame:Clone()
            frame.PetNameLabel.Text = pets[i]
			frame.Rarity.TextLabel.Text = PetsConfig.Pets[pets[i]].Rarity
			frame.Parent = self._gui.Main

            local poses = {
                [1] = 0.5,
                [2] = 0.28,
                [3] = 0.725,
            }

            frame.Position = UDim2.fromScale(poses[i], 0.6)

           	local whiteFlash = Assets.WhiteFrame:Clone()
			whiteFlash.Parent = self._gui.Main

            local flashTween = TweenService:Create(whiteFlash, TweenInfo.new(0.4), {BackgroundTransparency = 1})
            flashTween:Play()
            flashTween.Completed:Connect(function()
                whiteFlash:Destroy()
            end)

            local rotateTween = TweenService:Create(petOrtOffset, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Value = Vector3.new(0, 180, 0)})
            rotateTween:Play()

            local moveForwardTween = TweenService:Create(petPosOffset, TweenInfo.new(0.2), {Value = Vector3.new(0, 0, 1.5)})
            moveForwardTween:Play()
            moveForwardTween.Completed:Wait()

            local moveBackTween = TweenService:Create(petPosOffset, TweenInfo.new(0.4), {Value = Vector3.new(0, 0, 0)})
            moveBackTween:Play()
            moveBackTween.Completed:Wait()

            task.wait(1.25)

            local exitTween = TweenService:Create(petPosOffset, TweenInfo.new(0.4), {Value = Vector3.new(0, -10, 0)})
            exitTween:Play()

            local uiExitTween = TweenService:Create(frame, TweenInfo.new(0.4), {Position = UDim2.fromScale(poses[i], 3)})
            uiExitTween:Play()

            exitTween.Completed:Wait()
			self._controllers.GuiController.MainGui:Enable()
            task.wait(1)

            pet:Destroy()
            frame:Destroy()
        end)
    end
end

function HatchingController:Initialize()
    self._animatingObjects = {}

    RunService.RenderStepped:Connect(function()
        for k, v in pairs(self._animatingObjects) do
            if v ~= nil then
                if not v:FindFirstChild('posOffset') then
                    self._animatingObjects[k] = nil
                    continue
                end
                
                local posOffset = v.posOffset.Value
                local ortOffset = v.ortOffset.Value
                
                if v.Name == '1' then
                    local minOffset = -4.5
                    v:PivotTo(workspace.CurrentCamera.CFrame * CFrame.new(0 + posOffset.x, 0 + posOffset.y, minOffset + posOffset.z) * 
                        CFrame.Angles(math.rad(0 + ortOffset.x), math.rad(0 + ortOffset.y), math.rad(0 + ortOffset.z)))
                elseif v.Name == '2' then
                    local minOffset = -5
                    v:PivotTo(workspace.CurrentCamera.CFrame * CFrame.new(-3 + posOffset.x, 0 + posOffset.y, minOffset + posOffset.z) * 
                        CFrame.Angles(math.rad(0 + ortOffset.x), math.rad(30 + ortOffset.y), math.rad(0 + ortOffset.z)))
                elseif v.Name == '3' then
                    local minOffset = -5
                    v:PivotTo(workspace.CurrentCamera.CFrame * CFrame.new(3 + posOffset.x, 0 + posOffset.y, minOffset + posOffset.z) * 
                        CFrame.Angles(math.rad(0 + ortOffset.x), math.rad(-30 + ortOffset.y), math.rad(0 + ortOffset.z)))
                end
            end
        end
    end)

    EggOpened.OnClientEvent:Connect(function(eggId, pets)
        self:StartEggHatchingSequence(eggId, pets)
    end)
end

function HatchingController.new()
    return setmetatable(HatchingController, {__index = ControllerTemplate})
end

return HatchingController