local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local FoodCounterAsset = ReplicatedStorage.Assets.Food.FoodCounter

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local FoodCounter = {} :: ControllerTemplate.Type
local DefaultDuration = 3
local FollowingSpeed = 2

local function onCharacterAdded(self, character: Model)
    self._character = character
    local rootPart = self._character:WaitForChild("HumanoidRootPart")
    self._counter.CFrame = rootPart.CFrame * CFrame.new(0, 2, 3)
    self._lifeTime = DefaultDuration
    self._counter.Gui.Enabled = false
    self._currentShowingFoodAmount = 0
end

function FoodCounter:TweenPop()
    if self._isTweening then return end

    self._isTweening = true
    local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenUp = TweenService:Create(self._counter.Gui.Frame, tweenInfo, {Size = UDim2.fromScale(1, 1)})
    local tweenDown = TweenService:Create(self._counter.Gui.Frame, tweenInfo, {Size = UDim2.fromScale(.8, .8)})

    tweenUp:Play()
    tweenUp.Completed:Wait()
	tweenDown:Play()
    tweenDown.Completed:Wait()

    self._isTweening = false
end

function FoodCounter:AddFood(amount: number)
    self._currentShowingFoodAmount += amount
    self._counter.Gui.Enabled = true
    self._lifeTime = 0

    self._counter.Gui.Frame.CountLabel.Text = "+" .. self._utils.FormatNumber(self._currentShowingFoodAmount)
    self:TweenPop()
end

function FoodCounter:AfterPlayerLoaded(player: Player)
    self._counter = FoodCounterAsset:Clone()
    self._counter.Parent = workspace.Debris
    self._currentShowingFoodAmount = 0

    local character = player.Character or player.CharacterAdded:Wait()
    onCharacterAdded(self, character)

    player.CharacterAdded:Connect(function(newCharacter: Model)
        onCharacterAdded(self, newCharacter)
    end)

    RunService.Heartbeat:Connect(function(deltaTime)
        if (not self._character:FindFirstChild("HumanoidRootPart")) or (not self._character:FindFirstChild("Humanoid")) or self._character.Humanoid.Health <= 0 then return end

        local rootPart: Part = self._character.HumanoidRootPart
        local targetPosition = (rootPart.CFrame * CFrame.new(0, 2, 3)).Position
        local currentPosition = self._counter.Position
        self._counter.Position = currentPosition:Lerp(targetPosition, FollowingSpeed * deltaTime)
        self._lifeTime += deltaTime

        if self._lifeTime >= DefaultDuration then
            self._currentShowingFoodAmount = 0
            self._counter.Gui.Enabled = false
            self._lifeTime = 0
        end
    end)
end

function FoodCounter.new()
    local self = setmetatable(FoodCounter, {__index = ControllerTemplate})

    return self
end

return FoodCounter