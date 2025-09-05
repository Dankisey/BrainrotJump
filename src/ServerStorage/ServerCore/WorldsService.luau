local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WorldsConfig = require(ReplicatedStorage.Configs.WorldsConfig)

local Remotes = ReplicatedStorage.Remotes.Worlds
local WorldUnlocked = Remotes.WorldUnlocked
local WorldChanged = Remotes.WorldChanged
local GetSave = Remotes.GetSave

local ServerTypes = require(script.Parent.Parent.ServerTypes)
local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local WorldsService = {} :: ServerTypes.WorldsService

local function validateSave(save)
    save = save or {}

	save.CurrentWorld = save.CurrentWorld or 1
    save.UnlockedWorlds = save.UnlockedWorlds or {[1] = true}

    return save
end

function WorldsService:LoadSave(player: Player, save)
    self._playersSaves[player] = validateSave(save)
end

function WorldsService:UnloadSave(player: Player)
    local save = self._playersSaves[player]
    self._playersSaves[player] = nil

    return save
end

function WorldsService:Initialize()
    WorldChanged.OnServerEvent:Connect(function(player: Player, worldIndex: number)
        if not self._playersSaves[player] then return end

        if self._debounces[player] then return end

        self._debounces[player] = true

        task.delay(.3, function()
            self._debounces[player] = nil
        end)

        if not self._playersSaves[player].UnlockedWorlds[worldIndex] then
            return self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "World is not unlocked yet")
        end

        self._playersSaves[player].CurrentWorld = worldIndex
        player.CurrentWorld.Index.Value = worldIndex
    end)

    WorldUnlocked.OnServerEvent:Connect(function(player: Player, worldIndex: number)
        if not self._playersSaves[player] then return end

        if self._debounces[player] then return end

        self._debounces[player] = true

        task.delay(.3, function()
            self._debounces[player] = nil
        end)

        local worldInfo = WorldsConfig.Worlds[worldIndex]

        if not worldInfo then
            return warn("World witn index", worldIndex, "is not a part of WorldsConfig")
        end

        local price = worldInfo.PriceInWins

        if self._services.SoftCurrencyService:TrySpentCurrency(player, "Wins", price, "Gameplay", "WorldUnlock") then
            self._services.ServerMessagesSender:SendMessageToPlayer(player, "Congrats", string.format("%s World is successfully unlocked", worldInfo.PublicName))
            self._playersSaves[player].UnlockedWorlds[worldIndex] = true
            WorldUnlocked:FireClient(player, worldIndex)
        end
    end)

    GetSave.OnServerInvoke = function(player: Player)
        return self._playersSaves[player]
    end
end

function WorldsService.new()
	local self = setmetatable(WorldsService, {__index = ServiceTemplate})
    self._playersSaves = {}
    self._debounces = {}

    return self
end

return WorldsService