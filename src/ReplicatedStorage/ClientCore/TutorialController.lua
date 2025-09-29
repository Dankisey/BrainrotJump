local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Tutorial
local StepCompleted = Remotes.StepCompleted :: RemoteEvent
local GetSave = Remotes.GetSave :: RemoteFunction

local JumpEnded = ReplicatedStorage.Remotes.Brainrots.JumpEnded :: RemoteEvent

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local Config = require(ReplicatedStorage.Configs.TutorialConfig)

local TutorialController = {}

local progressFinishFunctions = {
    [1] = function(self)
        self._controllers.GuideBeamController:TryDestroyBeam("Tutorial", true)
        self._onStepCompleted()
    end;
    [2] = function(self)
        self._controllers.GuideBeamController:TryDestroyBeam("Tutorial", true)
        self._controllers.GuiController.TutorialGui.TutorialFrame:DeactivateGui()
        self._onStepCompleted()
    end;
    [3] = function(self)
        self._controllers.GuideBeamController:TryDestroyBeam("Tutorial")
        self._onStepCompleted()
    end;
    [4] = function(self)
        self._onStepCompleted()
    end;
    [5] = function(self)
        self._onStepCompleted()
    end;
    [6] = function(self)
        self._onStepCompleted()
        self.BlockFoodCollecting = false
    end;
    [7] = function(self)
        self._controllers.GuideBeamController:TryDestroyBeam("Tutorial", true)
        self._onStepCompleted()
    end;
    [8] = function(self)
        self._controllers.GuideBeamController:TryDestroyBeam("Tutorial", true)
        self._onStepCompleted()
    end;
    [9] = function(self)
        self._controllers.GuideBeamController:TryDestroyBeam("Tutorial", true)
        self._onStepCompleted()
    end;
    [10] = function(self)
        self._onStepCompleted()
    end;
    [11] = function(self)
        self._onStepCompleted()
    end;
    [12] = function(self)
        self._controllers.GuiController.TutorialGui.TutorialFrame:DeactivateGui()
        self._onStepCompleted()
    end;
}

local progressHandlingFunctions = {
    [1] = function(self)
        self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(1)
        self._controllers.GuiController.TutorialGui.TutorialFrame:UpdateFoodAmount(0, true)

        local targetPile = self._controllers.AutoCollectController:GetClosestFoodPileToPlayer()

        while not targetPile do
            task.wait(.5)
            targetPile = self._controllers.AutoCollectController:GetClosestFoodPileToPlayer()
        end

        self._controllers.GuideBeamController:CreateOrRedirectGuideBeamToPart("Tutorial", targetPile, 1)

        local food = self._player:WaitForChild("Currencies"):WaitForChild("Food")
        local connection

        connection = food.Changed:Connect(function()
            self._controllers.GuiController.TutorialGui.TutorialFrame:UpdateFoodAmount(food.Value, true)

            if food.Value >= Config.FoodAmount1 then
                connection:Disconnect()
                self.BlockFoodCollecting = true
                progressFinishFunctions[1](self)
            end
        end)
    end;
    [2] = function(self)
        self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(2)

        local target = self._controllers.ZoneController:GetBrainrotPoint()

        self._controllers.GuideBeamController:CreateOrRedirectGuideBeamToPart("Tutorial", target, -1)

        local connection
        connection = JumpEnded.OnClientEvent:Connect(function()
            task.wait(1.5)
            connection:Disconnect()
            progressFinishFunctions[2](self)
        end)
    end;
    [3] = function(self)
        self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(3)

        local target = self._controllers.ZoneController:GetSackPromptHolder()
        self._controllers.GuideBeamController:CreateOrRedirectGuideBeamToPart("Tutorial", target, -1)
    end;
    [4] = function(self)
        self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(4)
    end;
    [5] = function(self)
        self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(5)
    end;
    [6] = function(self)
        self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(6)
    end;
    [7] = function(self)
        self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(7)
        local targetPile = self._controllers.AutoCollectController:GetClosestFoodPileToPlayer()

        while not targetPile do
            task.wait(.5)
            targetPile = self._controllers.AutoCollectController:GetClosestFoodPileToPlayer()
        end

        self._controllers.GuideBeamController:CreateOrRedirectGuideBeamToPart("Tutorial", targetPile, 1)

        local food = self._player:WaitForChild("Currencies"):WaitForChild("Food")
        self._controllers.GuiController.TutorialGui.TutorialFrame:UpdateFoodAmount(food.Value, false)
        local connection

        connection = food.Changed:Connect(function()
            self._controllers.GuiController.TutorialGui.TutorialFrame:UpdateFoodAmount(food.Value, false)

            if food.Value >= Config.FoodAmount2 then
                connection:Disconnect()
                progressFinishFunctions[7](self)
            end
        end)
    end;
    [8] = function(self)
        self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(8)

        local target = self._controllers.ZoneController:GetBrainrotPoint()

        self._controllers.GuideBeamController:CreateOrRedirectGuideBeamToPart("Tutorial", target, -1)

        local connection
        connection = JumpEnded.OnClientEvent:Connect(function()
            task.wait(1.5)
            connection:Disconnect()
            progressFinishFunctions[8](self)
        end)
    end;
    [9] = function(self)
        task.delay(.5, function()
            self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(9)
            local eggsFolder = self._controllers.ZoneController:GetEggsFolder()
            local targetPosition = eggsFolder:WaitForChild("2").Position
            self._controllers.GuideBeamController:CreateOrRedirectGuideBeam("Tutorial", targetPosition, -1)
        end)
    end;
    [10] = function(self)
        task.delay(3, function()
            self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(10)
        end)
    end;
    [11] = function(self)
        self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(11)
    end;
    [12] = function(self)
        self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(12)
    end;
    [13] = function(self)
        local endFunction = function()
            self._controllers.GuiController.TutorialGui.TutorialFrame:ActivateGui(13)
            StepCompleted:FireServer(13)

            task.delay(Config.FinalLabelLifetime, function()
                self._controllers.GuiController.TutorialGui.TutorialFrame:DeactivateGui()
            end)

            self.TutorialCompleted = true
        end

        task.spawn(function()
            task.delay(1, function()
                endFunction()
            end)
        end)
    end;
}

function TutorialController:CompleteStep()
    if self.TutorialCompleted then return end
    progressFinishFunctions[self.CurrentStep](self)
end

function TutorialController:AfterPlayerLoaded(player: Player)
    self._player = player
    local save = GetSave:InvokeServer()

    if save.IsCompleted then self.TutorialCompleted = true end
    if save.IsCompleted then return end

    self.BlockFoodCollecting = false

    self._onStepCompleted = function()
        StepCompleted:FireServer(self.CurrentStep)
        self.CurrentStep += 1

        if progressHandlingFunctions[self.CurrentStep] then
            progressHandlingFunctions[self.CurrentStep](self)
        end
    end

    if not save.IsCompleted then
        if save.CurrentStep == Config.LastStep then
            StepCompleted:FireServer(Config.LastStep)
            self.TutorialCompleted = true
        else

            self.CurrentStep = save.CurrentStep

            if save.CurrentStep == 4  then
                self.CurrentStep = 7
            end

            if save.CurrentStep == 5 or save.CurrentStep == 6 then
                self.CurrentStep = save.CurrentStep + 3
            end

            if save.CurrentStep == 7 then
                self.CurrentStep = 13
            end

            task.wait(3)
            progressHandlingFunctions[self.CurrentStep](self)
        end
    end
end

function TutorialController.new()
    return setmetatable(TutorialController, {__index = ControllerTemplate})
end

return TutorialController