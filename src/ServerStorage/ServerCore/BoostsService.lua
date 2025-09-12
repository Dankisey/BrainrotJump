local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedTypes = require(ReplicatedStorage.Modules.SharedTypes)
local Remotes = ReplicatedStorage.Remotes.Boosts
local GetBoosts = Remotes.GetBoosts
local Updated = Remotes.Updated

local PermanentBoosts = require(ReplicatedStorage.Configs.PermanentBoostsConfig)
local ServerTypes = require(script.Parent.Parent.ServerTypes)
local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local BoostsService = {} :: ServerTypes.BoostsService

local function validateSave(save: SharedTypes.BoostsSave?) : SharedTypes.BoostsSave
    local validatedSave: SharedTypes.BoostsSave = save or {}

    validatedSave.TemporaryBoosts = validatedSave.TemporaryBoosts or {}
    validatedSave.PermanentBoosts = validatedSave.PermanentBoosts or {}

    return validatedSave
end

local function startUpdatingCycle(self: ServerTypes.BoostsService)
    while task.wait(1) do
        for player: Player, boosts: SharedTypes.BoostsSave in pairs(self._playerBoosts) do
            local expiredBoostNames = {} :: {string}

            for boostName: string, boostInfo: SharedTypes.TemporaryBoostData in pairs(boosts.TemporaryBoosts) do
                boostInfo.Duration -= 1

                if boostInfo.Duration <= 0 then
                    table.insert(expiredBoostNames, boostName)
                end
            end

            if #expiredBoostNames > 0 then
                for _, boostName in pairs(expiredBoostNames) do
                    self._playerBoosts[player].TemporaryBoosts[boostName] = nil
                end

                Updated:FireClient(player, self._playerBoosts[player])
            end
        end
    end
end

function BoostsService:GetBonus(player: Player, targetStat: string) : number
    local accumulatingFunction
    local currentModifier

    if targetStat == "Luck" then
        accumulatingFunction = function(a, b)
            return a + b
        end

        currentModifier = 0
    else
        accumulatingFunction = function(a, b)
            return a * b
        end

        currentModifier = 1
    end

    if not self._playerBoosts[player] then return currentModifier end

    for _, boostInfo in pairs(self._playerBoosts[player].TemporaryBoosts) do
        if boostInfo.ModifiedStats[targetStat] then
            currentModifier = accumulatingFunction(currentModifier, boostInfo.ModifiedStats[targetStat])
        end
    end

    for boostName, level: number in pairs(self._playerBoosts[player].PermanentBoosts) do
        local boostValue = nil

        if PermanentBoosts.Boosts[boostName].IsLevelBased then
            if not PermanentBoosts.Boosts[boostName].ModifiedStats[level][targetStat] then continue end

            boostValue = PermanentBoosts.Boosts[boostName].ModifiedStats[level][targetStat]
        else
            if not PermanentBoosts.Boosts[boostName].ModifiedStats[targetStat] then continue end

            boostValue = PermanentBoosts.Boosts[boostName].ModifiedStats[targetStat]
        end

        if boostValue then
            currentModifier = accumulatingFunction(currentModifier, boostValue)
        end
    end

    return currentModifier
end

function BoostsService:TryAddTemporaryBoost(player: Player, name: string, data: SharedTypes.TemporaryBoostData) : boolean
    if not self._playerBoosts[player] then return false end

    if self._playerBoosts[player].TemporaryBoosts[name] then
        self._playerBoosts[player].TemporaryBoosts[name].Duration += data.Duration
    else
        self._playerBoosts[player].TemporaryBoosts[name] = {
            ModifiedStats = data.ModifiedStats;
            Duration = data.Duration;
        }
    end

    Updated:FireClient(player, self._playerBoosts[player])

    return true
end

function BoostsService:CreateOrUpdateLeveledPermanentBoost(player: Player, name: string)
    if (not self._playerBoosts[player]) or (not PermanentBoosts.Boosts[name].IsLevelBased) then return end

    if self._playerBoosts[player].PermanentBoosts[name] then
        self._playerBoosts[player].PermanentBoosts[name] = math.min(self._playerBoosts[player].PermanentBoosts[name] + 1, #PermanentBoosts.Boosts[name].ModifiedStats)
    else
        self._playerBoosts[player].PermanentBoosts[name] = 1
    end

    Updated:FireClient(player, self._playerBoosts[player])
end

function BoostsService:AddPermanentBoost(player: Player, name: string, level: number?) : boolean
    if not self._playerBoosts[player] then return false end

    if level then
        self._playerBoosts[player].PermanentBoosts[name] = level
    else
        self._playerBoosts[player].PermanentBoosts[name] = true
    end

    Updated:FireClient(player, self._playerBoosts[player])

    return true
end

function BoostsService:LoadSave(player: Player, boostsSave: SharedTypes.BoostsSave?)
    boostsSave = validateSave(boostsSave)

    if player:GetAttribute("OwnsPremium") then
        boostsSave.PermanentBoosts.Premium = true
    else
        boostsSave.PermanentBoosts.Premium = nil
    end

    self._playerBoosts[player] = boostsSave
    Updated:FireClient(player, self._playerBoosts[player])
end

function BoostsService:UnloadSave(player: Player)
    local save = self._playerBoosts[player]
    self._playerBoosts[player] = nil

    return save
end

function BoostsService:Initialize()
    task.spawn(startUpdatingCycle, self)

    GetBoosts.OnServerInvoke = function(player: Player)
        return self._playerBoosts[player]
    end
end

function BoostsService.new() : ServerTypes.BoostsService
	local self = setmetatable(BoostsService, {__index = ServiceTemplate})
    self._playerBoosts = {}

	return self
end

return BoostsService