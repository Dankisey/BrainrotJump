local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local TranslateRange = require(ReplicatedStorage.Modules.Utils.TranslateRange)
local PilesConfig = require(ReplicatedStorage.Configs.PilesConfig)
local PilesAssets = ReplicatedStorage.Assets.Piles

local PileView = {}

local function setView(self, pileType: string, stage: number)
    self._currentView = PilesAssets[pileType][tostring(stage)]:Clone()
    self._currentView:PivotTo(self._spot.CFrame)
    self._currentView.Parent = self._spot
    self._currentScaleFactor = self._currentView:GetScale()
end

local function stopAnimations(self)
    if self._currentTween then
        self._currentTween:Cancel()
        self._scaleValue.Value = 1
    end
end

local function animate(self)
    stopAnimations(self)
    self._currentTween = TweenService:Create(self._scaleValue, TweenInfo.new(.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, true), {Value = .8})
    self._currentTween:Play()
end

local function onAmountChanged(self)
    if not self._currentView then return end

    local currentAmount = self._spot:GetAttribute("FoodLeft") or 0

    if currentAmount == 0 and self._currentView then
        stopAnimations(self)
        self._currentView:Destroy()
        self._currentView = nil

        return
    end

    local pileType = self._spot:GetAttribute("CurrentPile") or "None"

    if pileType == "None" or (not PilesConfig.Piles[pileType]) then return end

    local foodAmountPerStage = PilesConfig.Piles[pileType].MaxCapacity / PilesConfig.ViewStages
    local stage = math.ceil(currentAmount / foodAmountPerStage)

    if tostring(stage) ~= self._currentView.Name then
        stopAnimations(self)
        self._currentView:Destroy()
        setView(self, pileType, stage)
    end

    animate(self)
end

local function onTypeChanged(self)
    local pileType = self._spot:GetAttribute("CurrentPile") or "None"

    if self._currentView and pileType == "None" then
        stopAnimations(self)
        self._currentView:Destroy()
        self._currentView = nil
    end

    if pileType == "None" then return end

    setView(self, pileType, PilesConfig.ViewStages)
end

local function initialize(self)
    self._scaleValue = Instance.new("NumberValue")
    self._scaleValue.Value = 1

    self._scaleObjectConnection = self._scaleValue.Changed:Connect(function(value)
        if self._currentView and self._currentScaleFactor then
            self._currentView:ScaleTo(TranslateRange(0, 1, 0, self._currentScaleFactor, value))
        end
    end)

    self._pileTypeConnection = self._spot:GetAttributeChangedSignal("CurrentPile"):Connect(function()
        onTypeChanged(self)
    end)

    self._pileFoodConnection = self._spot:GetAttributeChangedSignal("FoodLeft"):Connect(function()
        if self._spot:GetAttribute("CurrentPile") ~= "None" and (not self._currentView) then
            onTypeChanged(self)
        end

        onAmountChanged(self)
    end)

    onTypeChanged(self)
end

function PileView:Destroy()
    stopAnimations(self)

    if self._pileTypeConnection then
        self._pileTypeConnection:Disconnect()
    end

    if self._pileFoodConnection then
        self._pileFoodConnection:Disconnect()
    end

    if self._scaleObjectConnection then
        self._scaleObjectConnection:Disconnect()
    end

    if self._scaleValue then
        self._scaleValue:Destroy()
    end

    if self._currentView then
        self._currentView:Destroy()
    end

    table.clear(self)
end

function PileView.new(spot: Part)
    local self = setmetatable({}, {__index = PileView})
    self._spot = spot
    initialize(self)

    return self
end

return PileView