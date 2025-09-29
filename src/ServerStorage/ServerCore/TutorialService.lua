local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Tutorial
local StepCompleted = Remotes.StepCompleted
local GetSave = Remotes.GetSave

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)
local Config = require(ReplicatedStorage.Configs.TutorialConfig)

local TutorialService = {}

function TutorialService:LoadSave(player: Player, save)
    self._playerSaves[player] = save or {
        IsCompleted = false;
        CurrentStep = 1;
    }
end

function TutorialService:UnloadSave(player: Player)
    local save = self._playerSaves[player]
    self._playerSaves[player] = nil

    return save
end

function TutorialService:Initialize()
    GetSave.OnServerInvoke = function(player: Player)
        return self._playerSaves[player]
    end

    StepCompleted.OnServerEvent:Connect(function(player: Player, stepIndex: number)
        if not self._playerSaves[player] then return end

        if stepIndex == 3 or stepIndex == 4 or stepIndex == 5 or stepIndex == 9 
        or stepIndex == 10 or stepIndex == 11 then return end

        if stepIndex >= 6 and stepIndex <= 8 then
            stepIndex -= 3
        end

        if stepIndex == 12 or stepIndex == 13 then
            stepIndex -= 6
        end

        self._services.Analytics:LogOnboardingFunnel(player, (stepIndex + 1))

        self._playerSaves[player].CurrentStep = math.min(stepIndex + 1, Config.LastStep)

        if stepIndex == Config.LastStep then
            self._playerSaves[player].IsCompleted = true
            print("Tutorial Completed")
        end
    end)
end

function TutorialService:IsTutorialCompleted(player: Player)
    return self._playerSaves[player] and self._playerSaves[player].IsCompleted
end

function TutorialService:GetCurrentStep(player: Player)
    return if self._playerSaves[player] then self._playerSaves[player].CurrentStep else 1
end

function TutorialService.new()
	local self = setmetatable(TutorialService, {__index = ServiceTemplate})
    self._playerSaves = {}

	return self
end

return TutorialService