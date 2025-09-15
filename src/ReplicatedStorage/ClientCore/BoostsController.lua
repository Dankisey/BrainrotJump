local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Boosts
local GetBoosts = Remotes.GetBoosts
local Updated = Remotes.Updated

local PermanentBoosts = require(ReplicatedStorage.Configs.PermanentBoostsConfig)
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local ClientTypes = require(ReplicatedStorage.Modules.ClientTypes)

local BoostsController = {} :: ClientTypes.BoostsController

local function recalculatePowerMultiplier(self: ClientTypes.BoostsController)
    local accumulatingFunction = function(a, b)
        return a * b
    end

    local modifier = 1

    if self._boosts.TemporaryBoosts then
        for _, boostInfo in pairs(self._boosts.TemporaryBoosts) do
            if boostInfo.ModifiedStats.Power then
                modifier = accumulatingFunction(modifier, boostInfo.ModifiedStats.Power)
            end
        end
    end

    if self._boosts.PermanentBoosts then
        for boostName, level: number in pairs(self._boosts.PermanentBoosts) do
            local boostValue = nil

            if PermanentBoosts.Boosts[boostName].IsLevelBased then
                if not PermanentBoosts.Boosts[boostName].ModifiedStats[level].Power then continue end

                boostValue = PermanentBoosts.Boosts[boostName].ModifiedStats[level].Power
            else
                if not PermanentBoosts.Boosts[boostName].ModifiedStats.Power then continue end

                boostValue = PermanentBoosts.Boosts[boostName].ModifiedStats.Power
            end

            if boostValue then
                modifier = accumulatingFunction(modifier, boostValue)
            end
        end
    end

    if self._currentPowerMultiplier ~= modifier then
        self.PowerMultiplierChanged:Invoke(modifier)
        self._currentPowerMultiplier = modifier
    end
end

local function recalculateMultipliers(self: ClientTypes.BoostsController)
    -- recalculatePowerMultiplier(self)
end

function BoostsController:GetBoostLevel(boostName: string) : number
    if (not self._boosts.PermanentBoosts) or (not self._boosts.PermanentBoosts[boostName]) or (not PermanentBoosts.Boosts[boostName].IsLevelBased) then return end

    return self._boosts.PermanentBoosts[boostName]
end

function BoostsController:GetBoosts()
    return self._boosts
end

function BoostsController:AfterPlayerLoaded(player: Player)

end

function BoostsController:Initialize()
    self._boosts = GetBoosts:InvokeServer() or {}
    recalculateMultipliers(self)

    Updated.OnClientEvent:Connect(function(boosts)
        self._boosts = boosts
        recalculateMultipliers(self)
        self.BoostsUpdated:Invoke(boosts)
    end)
end

function BoostsController:InjectUtils(utils)
    self.PowerMultiplierChanged = utils.Event.new()
    self.BoostsUpdated = utils.Event.new()
    self._utils = utils
end

function BoostsController.new()
    local self = setmetatable(BoostsController, {__index = ControllerTemplate})
    self._currentPowerMultiplier = 1
    self._boosts = {}

    return self
end

return BoostsController