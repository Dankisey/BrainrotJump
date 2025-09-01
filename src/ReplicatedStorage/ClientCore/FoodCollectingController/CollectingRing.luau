local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Asset = ReplicatedStorage.Assets.Food.CollectingRing

local CollectingRing = {}
local ringHeight = .01

local function spawnRing(self, character: Model)
    self._ring = Asset:Clone()
    self._ring.Parent = character

    local rootPart = character:WaitForChild("HumanoidRootPart")
    local centerCframe, size = character:GetBoundingBox()
    local heightDifference = (centerCframe.Position.Y - rootPart.Position.Y)

    local weld = Instance.new("Weld")
    weld.Parent = self._ring
    weld.Part0 = rootPart
    weld.Part1 = self._ring
    weld.C0 = CFrame.new(-Vector3.yAxis * (size.Y * .4 - heightDifference))
end

local function initialize(self)
    local character = self._player.Character or self._player.CharacterAdded:Wait()
    self._currentRadius = self._player:GetAttribute("CollectingRadius") or 1
    spawnRing(self, character)

    self._player:GetAttributeChangedSignal("CollectingRadius"):Connect(function()
        self._currentRadius = self._player:GetAttribute("CollectingRadius")
        self:AdjustSize(self._currentRadius)
    end)

    self:AdjustSize(self._currentRadius)

    self._player.CharacterAdded:Connect(function(character: Model)
        spawnRing(self, character)
        self:AdjustSize(self._currentRadius)
    end)
end

function CollectingRing:AdjustSize(collectingRadius: number)
    local info = TweenInfo.new(.5, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(self._ring, info, {Size = Vector3.new(collectingRadius * 2, ringHeight, collectingRadius * 2)})
    tween:Play()
end

function CollectingRing.new(player: Player)
    local self = setmetatable({}, {__index = CollectingRing})
    self._player = player
    initialize(self)

    return self
end

return CollectingRing