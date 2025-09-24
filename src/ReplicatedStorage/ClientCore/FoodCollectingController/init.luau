local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FoodCollectingConfig = require(ReplicatedStorage.Configs.FoodCollectingConfig)
local PilesConfig = require(ReplicatedStorage.Configs.PilesConfig)
local CollectingRing = require(script.CollectingRing)
local SackFiller = require(script.SackFiller)
local FoodCollected = ReplicatedStorage.Remotes.Piles.FoodCollected

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local FoodCollectingController = {} :: ControllerTemplate.Type

local function getPilesWithFoodInRange(self)
    local playerPosition = self._player.Character:GetPivot().Position :: Vector3
    local playerPosition2D = Vector2.new(playerPosition.X, playerPosition.Z)
    local piles = {}

    for _, pileSpot: Part in pairs(self._pileSpots) do
        local pileType = pileSpot:GetAttribute("CurrentPile")

        if (not pileType) or pileType == "None" then continue end

        local foodLeft = pileSpot:GetAttribute("FoodLeft") or 0

        if foodLeft <= 0 then continue end

        local distance2d = (Vector2.new(pileSpot.Position.X, pileSpot.Position.Z) - playerPosition2D).Magnitude

        if distance2d <= self._currentRadius + PilesConfig.CollectingOffset then
            table.insert(piles, pileSpot)
        end
    end

    return piles
end

local function tryCollectFood(self)
    if not self._player.Character then return false end
    if self._controllers.BrainrotController.IsJumping then return false end

    local playerPosition = self._player.Character:GetPivot().Position :: Vector3
    local availablePiles = getPilesWithFoodInRange(self) :: {Part}
    local collectedSpots = {}

	if #availablePiles > 0 and self._food.Value >= self._currentSackCapacity then
        self.CapReached:Invoke()

        return
    end

    table.sort(availablePiles, function(partA: Part, partB: Part)
        return (partA.Position - playerPosition).Magnitude > (partB.Position - playerPosition).Magnitude
    end)

    while (#collectedSpots < self._collectingPiles) and #availablePiles > 0 do
        table.insert(collectedSpots, table.remove(availablePiles))
    end

    if #collectedSpots < 1 then return false end

    FoodCollected:FireServer(collectedSpots)

    return true
end

function FoodCollectingController:AfterPlayerLoaded(player: Player)
    self._player = player
    self._ring = CollectingRing.new(player)
	self._sackFiller = SackFiller.new(player)
    self._currentRadius = self._player:GetAttribute("CollectingRadius") or 1

    self._collectingPiles = self._player:GetAttribute("CollectingPiles") or 1

    self._player:GetAttributeChangedSignal("CollectingPiles"):Connect(function()
        self._collectingPiles = self._player:GetAttribute("CollectingPiles")
    end)

    local collectingSpeedMultiplier = self._player:GetAttribute("CollectingSpeedMultiplier") or 1
    self._collectingTickTime = FoodCollectingConfig.CollectingTickTime / collectingSpeedMultiplier

    self._player:GetAttributeChangedSignal("CollectingSpeedMultiplier"):Connect(function()
        collectingSpeedMultiplier = self._player:GetAttribute("CollectingSpeedMultiplier")
        self._collectingTickTime = FoodCollectingConfig.CollectingTickTime / collectingSpeedMultiplier
    end)

    self._pileSpots = self._controllers.ZoneController:GetZone().FoodPileSpots:GetChildren()
	self._currentSackCapacity = self._player:GetAttribute("FoodCapacity") or 1
    self._food = self._player:WaitForChild("Currencies"):WaitForChild("Food")

    self._player:GetAttributeChangedSignal("FoodCapacity"):Connect(function()
		self._currentSackCapacity = self._player:GetAttribute("FoodCapacity")
    end)

    task.spawn(function()
        while task.wait(self._collectingTickTime) do
            tryCollectFood(self)
        end
    end)
end

function FoodCollectingController:InjectUtils(utils)
    self.CapReached = utils.Event.new()
    self._utils = utils
end

function FoodCollectingController.new()
    local self = setmetatable(FoodCollectingController, {__index = ControllerTemplate})

    return self
end

return FoodCollectingController