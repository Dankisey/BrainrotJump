local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes

local BrainrotConfig = require(ReplicatedStorage.Configs.BrainrotConfig)

local Players = game:GetService("Players")

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)
export type BrainrotService = {
    _brainrots: {[Player]: {
        BrainrotLevel: number;
        BrainrotXP: number;
    }}
} & ServiceTemplate.Type

local BrainrotService = {} :: BrainrotService

local function spawnBrainrotForPlayer(self: BrainrotService, player: Player)
    local brainrotLevel = self._brainrots[player].BrainrotLevel
    local model = BrainrotConfig.Brainrots[brainrotLevel].Model
    local zone = self._services.ZonesService:GetPlayerZone(player)

    for _, child in zone.BrainrotPoint:GetChildren() do
        child:Destroy()
    end

    -- model.Parent = zone.BrainrotPoint
    model:PivotTo(zone.BrainrotPoint.CFrame)
end

local function upgradeBrainrot(self: BrainrotService, player: Player)
    local currentLevel = self._brainrots[player].BrainrotLevel

    if self._brainrots[player].BrainrotXP < BrainrotConfig.Brainrots[currentLevel].XpToNextLevel then return end

    self._brainrots[player] = {
        BrainrotLevel = currentLevel + 1;
        BrainrotXP = 0;
    }

    -- give 1 updrage point to player

    -- update brainrot gui

    spawnBrainrotForPlayer(self, player)
end

local function startFeedingProcess(self: BrainrotService, player: Player)
    local amount = player.Currencies.Food.Value
    player.Currencies.Food.Value = 0

    self._brainrots[player].BrainrotXP += amount
    local currentLevel = self._brainrots[player].BrainrotLevel

    -- spawn VFX

    -- update brainrot gui

    if self._brainrots[player].BrainrotXP >= BrainrotConfig.Brainrots[currentLevel].XpToNextLevel then
        upgradeBrainrot(self, player)
    end
end

function BrainrotService:LoadPlayer(player: Player, data)
    local data = data or {
        BrainrotLevel = 1;
        BrainrotXP = 0;
    }

    local zone = self._services.ZonesService:GetPlayerZone(player)

    if not zone then
        while task.wait(1) do
            zone = self._services.ZonesService:GetPlayerZone(player)

            if zone then break end
        end
    end

    local feedingCircle = zone.FeedingCircle

    feedingCircle.Touched:Connect(function(otherPart: Part)
        local character: Model = otherPart.Parent
	    local touchedPlayer: Player = Players:GetPlayerFromCharacter(character)

	    if not touchedPlayer then return end

        if touchedPlayer ~= player then return end

	    if self._debounces[touchedPlayer] then return end

	    self._debounces[touchedPlayer] = true

        startFeedingProcess(self, player)

	    task.spawn(function()
		    task.wait(1)
		    self._debounces[touchedPlayer] = nil
	    end)
    end)

    self._brainrots[player] = data
    spawnBrainrotForPlayer(self, player)
end

function BrainrotService:UnloadPlayer(player: Player)
    local data = self._brainrots[player] or {}

    return data
end

function BrainrotService:Initialize()
    self._brainrots = {}
    self._debounces = {}
end

function BrainrotService.new()
    local self = setmetatable(BrainrotService, {__index = ServiceTemplate})
    self._occupiedZonesData = {}

    return self
end

return BrainrotService