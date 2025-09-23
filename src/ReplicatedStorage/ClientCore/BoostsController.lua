local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Boosts
local GetBoosts = Remotes.GetBoosts
local Updated = Remotes.Updated

local PermanentBoosts = require(ReplicatedStorage.Configs.PermanentBoostsConfig)
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local ClientTypes = require(ReplicatedStorage.Modules.ClientTypes)

local BoostsController = {} :: ClientTypes.BoostsController

local function recalculateMultiplier(self: ClientTypes.BoostsController, stat: string)
    local accumulatingFunction = function(a, b)
        return a * b
    end

    local multiplier = 1

    if self._boosts.TemporaryBoosts then
        for _, boostInfo in pairs(self._boosts.TemporaryBoosts) do
            if boostInfo.ModifiedStats[stat] then
                multiplier = accumulatingFunction(multiplier, boostInfo.ModifiedStats[stat])
            end
        end
    end

    if self._boosts.PermanentBoosts then
        for boostName, level: number in pairs(self._boosts.PermanentBoosts) do
            local boostValue = nil

            if PermanentBoosts.Boosts[boostName].IsLevelBased then
                if not PermanentBoosts.Boosts[boostName].ModifiedStats[level][stat] then continue end

                boostValue = PermanentBoosts.Boosts[boostName].ModifiedStats[level][stat]
            else
                if not PermanentBoosts.Boosts[boostName].ModifiedStats[stat] then continue end

                boostValue = PermanentBoosts.Boosts[boostName].ModifiedStats[stat]
            end

            if boostValue then
                multiplier = accumulatingFunction(multiplier, boostValue)
            end
        end
    end

    return multiplier
end

local function recalculateMultipliers(self: ClientTypes.BoostsController)
    local cashMultiplier = recalculateMultiplier(self, "Cash")

    if cashMultiplier ~= self._cashMultiplier then
        self._cashMultiplier = cashMultiplier
        self.CashMultiplierChanged:Invoke(cashMultiplier)
    end
end

function BoostsController:GetBoostLevel(boostName: string) : number
    if (not self._boosts.PermanentBoosts) or (not self._boosts.PermanentBoosts[boostName]) or (not PermanentBoosts.Boosts[boostName].IsLevelBased) then return end

    return self._boosts.PermanentBoosts[boostName]
end

function BoostsController:GetCashMultiplier()
    return self._cashMultiplier
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
    self.CashMultiplierChanged = utils.Event.new()
    self.BoostsUpdated = utils.Event.new()
    self._utils = utils
end

function BoostsController.new()
    local self = setmetatable(BoostsController, {__index = ControllerTemplate})
    self._currentCashMultipler = 1
    self._boosts = {}

    return self
end

return BoostsController