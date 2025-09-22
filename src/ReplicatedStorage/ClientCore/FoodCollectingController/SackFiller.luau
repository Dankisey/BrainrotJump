local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SackFillers = ReplicatedStorage.Assets.SackFillers

local SackFiller = {}

local function updateSackFillView(self)
    local character = self._player.Character or self._player.CharacterAdded:Wait()
    local sackModel = character:WaitForChild("Sack")

    local currentFillers = SackFillers:WaitForChild(self._sack.Value)
    local fillersAmount = #currentFillers:GetChildren()
    local foodPerFillerLevel = self._currentSackCapacity / fillersAmount
    local currentFillerIndex = math.ceil(self._food.Value / foodPerFillerLevel)
    currentFillerIndex = math.min(currentFillerIndex, fillersAmount)

    if self._lastViewIndex == currentFillerIndex then return end

    self._lastViewIndex = currentFillerIndex

    if self._lastView then
        self._lastView:Destroy()
    end

    if currentFillerIndex == 0 then return end

    self._lastView = currentFillers:WaitForChild(tostring(currentFillerIndex)):Clone()
    self._lastView:PivotTo(sackModel:GetPivot())
    self._lastView.Parent = sackModel

    local weld = Instance.new("Weld")
    weld.Parent = self._lastView.PrimaryPart
    weld.Part0 = self._lastView.PrimaryPart
    weld.Part1 = sackModel.PrimaryPart
    weld.Enabled = true
end

local function initialize(self)
    self._sack = self._player:WaitForChild("Equipment"):WaitForChild("Sack")
    self._food = self._player:WaitForChild("Currencies"):WaitForChild("Food")
    self._currentSackCapacity = self._player:GetAttribute("FoodCapacity") or 1
    self._lastViewIndex = 0

    self._player:GetAttributeChangedSignal("FoodCapacity"):Connect(function()
        self._currentSackCapacity = self._player:GetAttribute("FoodCapacity")
        updateSackFillView(self)
    end)

    self._player.CharacterAdded:Connect(function()
        self._lastView = nil
        self._lastViewIndex = nil
        updateSackFillView(self)
    end)

    self._sack.Changed:Connect(function()
        self._lastView = nil
        self._lastViewIndex = nil
        updateSackFillView(self)
    end)

    self._food.Changed:Connect(function()
        updateSackFillView(self)
    end)

    updateSackFillView(self)
end

function SackFiller.new(player: Player)
    local self = setmetatable({}, {__index = SackFiller})
    self._player = player
    initialize(self)

    return self
end

return SackFiller