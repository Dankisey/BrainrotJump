local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local Config = require(ReplicatedStorage.Configs.TutorialConfig)

local TutorialFrame = {}

local activationFunctions = {
    [1] = function(self)
        self._guiObjects[1].Visible = true
        self._currentActivatedObject = 1
    end;
    [2] = function(self)
        self._guiObjects[2].Visible = true
        self._currentActivatedObject = 2
    end;
    [3] = function(self)
        self._guiObjects[3].Visible = true
        self._currentActivatedObject = 3
    end;
    [4] = function(self)
        self._guiObjects[4].Visible = true
        self._currentActivatedObject = 4
        self._tween = TweenService:Create(
            self._guiObjects[4],
            TweenInfo.new(.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true),
            {Position = UDim2.fromScale(0.285, 0.294)}
        )
        self._tween:Play()
    end;
    [5] = function(self)
        self._guiObjects[5].Visible = true
        self._currentActivatedObject = 5
        self._tween = TweenService:Create(
            self._guiObjects[5],
            TweenInfo.new(.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true),
            {Position = UDim2.fromScale(0.58, 0.668)}
        )
        self._tween:Play()
    end;
    [6] = function(self)
        self._guiObjects[6].Visible = true
        self._currentActivatedObject = 6
        self._tween = TweenService:Create(
            self._guiObjects[6],
            TweenInfo.new(.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true),
            {Position = UDim2.fromScale(0.68, 0.15)}
        )
        self._tween:Play()
    end;
    [7] = function(self)
        self._guiObjects[7].Visible = true
        self._currentActivatedObject = 7
    end;
    [8] = function(self)
        self._guiObjects[8].Visible = true
        self._currentActivatedObject = 8
    end;
    [9] = function(self)
        self._guiObjects[9].Visible = true
        self._currentActivatedObject = 9
    end;
    [10] = function(self)
        self._guiObjects[10].Visible = true
        self._currentActivatedObject = 10
        self._tween = TweenService:Create(
            self._guiObjects[10].PointerPets,
            TweenInfo.new(.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true),
            {Position = UDim2.fromScale(0.11, 0.403)}
        )
        self._tween:Play()
    end;
    [11] = function(self)
        self._guiObjects[11].Visible = true
        self._currentActivatedObject = 11
        self._tween = TweenService:Create(
            self._guiObjects[11],
            TweenInfo.new(.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true),
            {Position = UDim2.fromScale(0.467, 0.6)}
        )
        self._tween:Play()
    end;
    [12] = function(self)
        self._guiObjects[12].Visible = true
        self._currentActivatedObject = 12
        self._tween = TweenService:Create(
            self._guiObjects[12],
            TweenInfo.new(.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true),
            {Position = UDim2.fromScale(0.68, 0.13)}
        )
        self._tween:Play()
    end;
    [13] = function(self)
        self._guiObjects[13].Visible = true
        self._currentActivatedObject = 13
    end;
}

function TutorialFrame:UpdateFoodAmount(value: number, first: boolean)
    if first then
        self._guiObjects[1].Label.Text = "Collect food: " .. value .. "/" .. Config.FoodAmount1
    else
        self._guiObjects[7].Label.Text = "Collect food: " .. value .. "/" .. Config.FoodAmount2
    end
end

function TutorialFrame:ActivateGui(index)
    self:DeactivateGui()
    activationFunctions[index](self)
end

function TutorialFrame:DeactivateGui()
    if self._currentActivatedObject then
        self._guiObjects[self._currentActivatedObject].Visible = false
        self._currentActivatedObject = nil
    end

    if self._tween then
        self._tween:Cancel()
        self._tween = nil
    end
end

function TutorialFrame:Initialize()
    self._guiObjects = {
        [1] = self._frame:WaitForChild("CollectFood");
        [2] = self._frame:WaitForChild("LaunchBrainrot");
        [3] = self._frame:WaitForChild("BuySackLabel");
        [4] = self._frame:WaitForChild("PointerSack");
        [5] = self._frame:WaitForChild("PointerBuy");
        [6] = self._frame:WaitForChild("PointerClose");
        [7] = self._frame:WaitForChild("CollectFood");
        [8] = self._frame:WaitForChild("LaunchBrainrot");
        [9] = self._frame:WaitForChild("HatchEggLabel");
        [10] = self._frame:WaitForChild("PetPointerAndLabel");
        [11] = self._frame:WaitForChild("PointerEquip");
        [12] = self._frame:WaitForChild("PointerClosePets");
        [13] = self._frame:WaitForChild("FinalMessage");
    }
end

function TutorialFrame.new(frame: Frame)
    local self = setmetatable(TutorialFrame, {__index = ControllerTemplate})
    self._frame = frame

    return self
end

return TutorialFrame