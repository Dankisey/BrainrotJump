local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BasketFillers = ReplicatedStorage.Assets.BasketFillers

local BasketFiller = {}

local function updateBasketFillView(self)
    local character = self._player.Character or self._player.CharacterAdded:Wait()
    local basketModel = character:WaitForChild("Basket")

    local currentFillers = BasketFillers:WaitForChild(self._basket.Value)
    local foodPerFillerLevel = self._currentBasketCapacity / #currentFillers:GetChildren()
    local currentFillerIndex = math.ceil(self._food.Value / foodPerFillerLevel)

    print(currentFillerIndex, self._currentBasketCapacity)
    if self._lastViewIndex == currentFillerIndex then return end

    self._lastViewIndex = currentFillerIndex

    if self._lastView then
        self._lastView:Destroy()
    end

    if currentFillerIndex == 0 then return end

    self._lastView = currentFillers:WaitForChild(tostring(currentFillerIndex)):Clone()
    self._lastView:PivotTo(basketModel:GetPivot())
    self._lastView.Parent = basketModel

    local weld = Instance.new("Weld")
    weld.Parent = self._lastView.PrimaryPart
    weld.Part0 = self._lastView.PrimaryPart
    weld.Part1 = basketModel.PrimaryPart
    weld.Enabled = true
end

local function initialize(self)
    self._basket = self._player:WaitForChild("Equipment"):WaitForChild("Basket")
    self._food = self._player:WaitForChild("Currencies"):WaitForChild("Food")
    self._currentBasketCapacity = self._player:GetAttribute("FoodCapacity") or 1
    self._lastViewIndex = 0

    self._player:GetAttributeChangedSignal("FoodCapacity"):Connect(function()
        self._currentBasketCapacity = self._player:GetAttribute("FoodCapacity")
        updateBasketFillView(self)
    end)

    self._player.CharacterAdded:Connect(function()
        self._lastView = nil
        self._lastViewIndex = nil
        updateBasketFillView(self)
    end)

    self._basket.Changed:Connect(function()
        self._lastView = nil
        self._lastViewIndex = nil
        updateBasketFillView(self)
    end)

    self._food.Changed:Connect(function()
        updateBasketFillView(self)
    end)

    updateBasketFillView(self)
end

function BasketFiller.new(player: Player)
    local self = setmetatable({}, {__index = BasketFiller})
    self._player = player
    initialize(self)

    return self
end

return BasketFiller