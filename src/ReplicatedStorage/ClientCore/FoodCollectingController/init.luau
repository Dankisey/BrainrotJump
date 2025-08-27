local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectingRing = require(script.CollectingRing)
local FoodCollected = ReplicatedStorage.Remotes.Piles.FoodCollected

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local FoodCollectingController = {} :: ControllerTemplate.Type
local collectingTickTime = .5

local function tryCollectFood(self)
    if not self._player.Character then return false end

    local playerPosition = self._player.Character:GetPivot().Position :: Vector3
    local nearestDistance = nil :: number?
    local nearestSpot = nil :: Part?

    for _, pileSpot: Part in pairs(self._pileSpots) do
        local pileType = pileSpot:GetAttribute("CurrentPile")

        if (not pileType) or pileType == "None" then continue end

        local foodLeft = pileSpot:GetAttribute("FoodLeft") or 0

        if foodLeft <= 0 then continue end

        local distance = (pileSpot.Position - playerPosition).Magnitude

        if (not nearestDistance) or distance < nearestDistance then
            nearestDistance = distance
            nearestSpot = pileSpot
        end
    end

    if not nearestSpot then return false end

    local distance2D = (Vector2.new(playerPosition.X, playerPosition.Z) - Vector2.new(nearestSpot.Position.X, nearestSpot.Position.Z)).Magnitude

    if distance2D > self._currentRadius then return false end

    FoodCollected:FireServer(nearestSpot)

    return true
end

function FoodCollectingController:AfterPlayerLoaded(player: Player)
    self._player = player
    self._ring = CollectingRing.new(player)
    self._collectingTickTime = collectingTickTime
    self._currentRadius = self._player:GetAttribute("CollectingRadius")

    if not self._currentRadius then
        self._player:GetAttributeChangedSignal("CollectingRadius"):Wait()
        self._currentRadius = self._player:GetAttribute("CollectingRadius")
    end

    self._ring:AdjustSize(self._currentRadius)

    self._player:GetAttributeChangedSignal("CollectingRadius"):Connect(function()
        self._currentRadius = self._player:GetAttribute("CollectingRadius")
        self._ring:AdjustSize(self._currentRadius)
    end)

    self._pileSpots = self._controllers.ZoneController:GetZone().FoodPileSpots:GetChildren()

    task.spawn(function()
        while task.wait(self._collectingTickTime) do
            tryCollectFood(self)
        end
    end)
end

function FoodCollectingController.new()
    local self = setmetatable(FoodCollectingController, {__index = ControllerTemplate})

    return self
end

return FoodCollectingController