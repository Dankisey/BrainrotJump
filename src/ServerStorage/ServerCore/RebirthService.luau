local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Requested = ReplicatedStorage.Remotes.Rebirth.Requested
local RebirthConfig = require(ReplicatedStorage.Configs.RebirthConfig)

local ServerTypes = require(script.Parent.Parent.ServerTypes)
local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local RebirthService = {} :: ServerTypes.RebirthService

local function validateSave(save: ServerTypes.RebirthSave?) : ServerTypes.RebirthSave
    save = save or {}
    save.Level = save.Level or 0

    return save
end

local function updateBonus(self: ServerTypes.RebirthService, player: Player)
    self._playersSaves[player].Level += 1
    self._services.BoostsService:CreateOrUpdateLeveledPermanentBoost(player, "Rebirth")
    player:SetAttribute("RebirthsAmount", self._playersSaves[player].Level)
end

local function resetValues(_: ServerTypes.RebirthService, player: Player)
    player.Currencies.Cash.Value = 0
end

function RebirthService:ApplyRebirthWithSkip(player: Player)
    updateBonus(self, player)
end

function RebirthService:LoadSave(player: Player, save: ServerTypes.RebirthSave)
    save = validateSave(save)
    self._playersSaves[player] = save
    player:SetAttribute("RebirthsAmount", self._playersSaves[player].Level)
end

function RebirthService:UnloadSave(player: Player) : ServerTypes.RebirthSave
    local save = self._playersSaves[player]
    self._playersSaves[player] = nil

    return save
end

function RebirthService:Initialize()
    Requested.OnServerEvent:Connect(function(player: Player)
        if not self._playersSaves[player] then return end

        if self._debounces[player] then return end

        self._debounces[player] = true
        local currentLevel = self._playersSaves[player].Level
        local price = RebirthConfig.Price.StartValue * (RebirthConfig.Price.Multiplier ^ currentLevel)
        local playerCash: IntValue = player.Currencies.Cash

        if playerCash.Value < price then
            self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "Not Enough Cash for Rebirth")
            self._debounces[player] = nil

            return
        end

        resetValues(self, player)
        updateBonus(self, player)
        self._debounces[player] = nil
    end)
end

function RebirthService.new()
    local self = setmetatable(RebirthService, {__index = ServiceTemplate})
    self._playersSaves = {}
    self._debounces = {}

    return self
end

return RebirthService