local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Piles
local FoodCollected = Remotes.FoodCollected

local PilesConfig = require(ReplicatedStorage.Configs.PilesConfig)

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)
export type PileService = {
    _occupiedZonesData: {[Model]: {
        PileTasks: {[Part]: thread};
        Player: Player;
    }}
} & ServiceTemplate.Type

local PileService = {} :: PileService

local function getNewPileType(self: PileService)
    return self._utils.GetChancedRewardIndex(PilesConfig.Piles)
end

local function respawnPile(spot: Part, pileType: string)
    spot:SetAttribute("CurrentPile", pileType)
    spot:SetAttribute("FoodLeft", PilesConfig.Piles[pileType].MaxCapacity)
end

local function emptyPile(spot: Part)
    spot:SetAttribute("FoodLeft", 0)
end

local function startRespawnCycle(self: PileService, spot: Part)
    local lastPileType = spot:GetAttribute("CurrentPile") or ""
    local zone = spot.Parent.Parent
    emptyPile(spot)

    if (not self._occupiedZonesData[zone]) or self._occupiedZonesData[zone].PileTasks[spot] then return end

    local regenerattionTime = if PilesConfig.Piles[lastPileType] then PilesConfig.Piles[lastPileType].RegenerationTime else PilesConfig.DefaultRegenerationTime

    self._occupiedZonesData[zone].PileTasks[spot] = task.delay(regenerattionTime, function()
        local pileType = getNewPileType(self)
        respawnPile(spot, pileType)

        self._occupiedZonesData[zone].PileTasks[spot] = nil
    end)
end

function PileService:Initialize()
    self._services.ZonesService.ZoneOccupied:Subscribe(self, function(player: Player, zone: Model)
        self._occupiedZonesData[zone] = {}
        self._occupiedZonesData[zone].PileTasks = {}
        self._occupiedZonesData[zone].Player = player

        for _, pileSpot in pairs(zone.FoodPileSpots:GetChildren()) do
            local pileType = getNewPileType(self)
            respawnPile(pileSpot, pileType)
        end
    end)

    self._services.ZonesService.ZoneCleared:Subscribe(self, function(player: Player, zone: Model)
        if not self._occupiedZonesData[zone] then return end

        for _, thread: thread in pairs(self._occupiedZonesData[zone].PileTasks) do
            task.cancel(thread)
        end

        for _, pileSpot in pairs(zone.FoodPileSpots:GetChildren()) do
            pileSpot:SetAttribute("CurrentPile", "None")
            emptyPile(pileSpot)
        end

        self._occupiedZonesData[zone] = nil
    end)

    FoodCollected.OnServerEvent:Connect(function(player: Player, spot: Part)
        local foodLeft = spot:GetAttribute("FoodLeft") or 0
        spot:SetAttribute("FoodLeft", foodLeft - 1)
        self._services.RewardService:GiveReward(player, {FunctionName = "Food", Data = 1})

        if foodLeft <= 0 then
            startRespawnCycle(self, spot)
        end
    end)
end

function PileService.new()
    local self = setmetatable(PileService, {__index = ServiceTemplate})
    self._occupiedZonesData = {}

    return self
end

return PileService