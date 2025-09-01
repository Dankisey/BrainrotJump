local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Asset = ReplicatedStorage.Assets.Food.CollectingRing

local CollectingRing = {}
local ringHeight = .01

local function spawnRing(self, character)
    self._ring = Asset:Clone()
    self._ring.Parent = character

    local rootPart = character:WaitForChild("HumanoidRootPart")
    local height = character:GetExtentsSize().Y

    local weld = Instance.new("Weld")
    weld.Parent = self._ring
    weld.Part0 = rootPart
    weld.Part1 = self._ring
    weld.C0 = CFrame.new(-Vector3.yAxis * (height * .24))
end

local function initialize(self)
    local character = self._player.Character or self._player.CharacterAdded:Wait()
    spawnRing(self, character)

    self._player.CharacterAdded:Connect(function(character: Model)
        spawnRing(self, character)
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