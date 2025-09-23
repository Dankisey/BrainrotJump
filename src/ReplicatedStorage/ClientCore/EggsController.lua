local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local EggConfig = require(ReplicatedStorage.Configs.EggConfig)
local AutoStopRequested = ReplicatedStorage.Remotes.Eggs.AutoStopRequested

local RunService = game:GetService("RunService")

local RobuxIcon = "rbxassetid://120243801977220"
local CoinIcon = "rbxassetid://18885492705"

local EggsController = {}

function EggsController:AfterPlayerLoaded(player: Player)
    self._player = player
    self._eggModels = {}

    local eggModels = workspace:WaitForChild("Eggs", 5)

    RunService.RenderStepped:Connect(function()
        local GetMoveVector = require(player:WaitForChild("PlayerScripts").PlayerModule:WaitForChild("ControlModule")):GetMoveVector()

		local character =  player.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
		local humanoid = character:FindFirstChild("Humanoid")

		if (GetMoveVector.X ~= 0 or GetMoveVector.Y ~= 0 or GetMoveVector.Z ~= 0) or humanoid:GetState() == Enum.HumanoidStateType.Freefall  then
			if player:GetAttribute("IsInAutoHatching") then
                AutoStopRequested:FireServer()
                self._inDebounce = true

                task.spawn(function()
                    task.wait(1)
                    self._inDebounce = false
                end)
			end
		end
    end)
end

function EggsController:Initialize()
    self._inDebounce = false

    local function onEggAdded(egg)
        task.spawn(function()
            egg:WaitForChild("CostGuiPart"):WaitForChild("CostGui").CostFrame.CostLabel.Text = self._utils.FormatNumber(EggConfig[egg.Name].Price)

            if EggConfig[egg.Name].Currency == "Robux" then
                egg.CostGuiPart.CostGui.CostFrame.ImageLabel.Image = RobuxIcon
            end
        end)
    end

    for _, egg in CollectionService:GetTagged("Egg") do
        onEggAdded(egg)
    end

    CollectionService:GetInstanceAddedSignal("Egg"):Connect(onEggAdded)
end

function EggsController:InjectUtils(utils)
    self.EggUnlocked = utils.Event.new()
    self._utils = utils
end

function EggsController.new()
    return setmetatable(EggsController, {__index = ControllerTemplate})
end

return EggsController