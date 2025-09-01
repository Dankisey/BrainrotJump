local Players = game:GetService("Players")
local PileView = require(script.PileView)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PilesConfig = require(ReplicatedStorage.Configs.PilesConfig)
local FoodCollected = ReplicatedStorage.Remotes.Piles.FoodCollected
local FoodVfx = ReplicatedStorage.Assets.FoodVfx

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

export type PilesReplicator = {
    _playerSpots: {[Player]: {Part}};
    _viewPerSpot: {[Part]: any};
} & ControllerTemplate.Type

local PilesReplicator = {} :: PilesReplicator

local function onPlayerRemoved(self: PilesReplicator, player: Player)
    if not self._playerSpots[player] then return end

    for _, spot: Player in pairs(self._playerSpots[player]) do
        if self._viewPerSpot[spot] then
            self._viewPerSpot[spot]:Destroy()
        end
    end

    self._playerSpots[player] = nil
end

local function onPlayerAdded(self: PilesReplicator, player: Player)
    if self._playerSpots[player] then return end

    local zone = self._controllers.ZoneController:GetPlayersZone(player)
    local spots = zone:WaitForChild("FoodPileSpots"):GetChildren()
    self._playerSpots[player] = {}

    for _, spot: Part in pairs(spots) do
        table.insert(self._playerSpots[player], spot)
        self._viewPerSpot[spot] = PileView.new(spot)
    end
end

function PilesReplicator:AfterPlayerLoaded(player: Player)
    self._random = Random.new(os.time())
    local character = player.Character or player.CharacterAdded:Wait()
    self._currentBasketPivot = character:WaitForChild("BasketPivot")

    player.CharacterAdded:Connect(function(newCharacter)
        self._currentBasketPivot = newCharacter:WaitForChild("BasketPivot")
    end)

    for _, player: Player in pairs(Players:GetPlayers()) do
        onPlayerAdded(self, player)
    end

    Players.PlayerAdded:Connect(function(player: Player)
        onPlayerAdded(self, player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        onPlayerRemoved(self, player)
    end)

    FoodCollected.OnClientEvent:Connect(function(spots: {Part}, amountToGive: number)
        local amountPerPile = amountToGive / #spots
        local vfxSpawners = {}

        for _, spot: Part in pairs(spots) do
            local pileType = spot:GetAttribute("CurrentPile") or "None"

            if pileType == "None" then continue end

            table.insert(vfxSpawners, {
                PileType = pileType;
                Amount = amountPerPile;
                Spawn = spot
            })
        end

        local arcData = PilesConfig.ArcData

        for _, spawnData in pairs(vfxSpawners) do
            local vfx = FoodVfx:Clone()
            vfx.Gui.Icon.Image = PilesConfig.Piles[spawnData.PileType].Icon
            vfx.Parent = workspace.Debris

            self._controllers.ArcBuilder:AddArc(vfx, spawnData.Spawn.Position, self._currentBasketPivot,
                arcData.Duration, arcData.Length, self._random:NextInteger(arcData.Angles.Min, arcData.Angles.Max))
        end
    end)
end

function PilesReplicator.new()
    local self = setmetatable(PilesReplicator, {__index = ControllerTemplate})
    self._playerSpots = {} :: {[Player]: {Part}}
    self._viewPerSpot = {} :: {[Part]: any}

    return self
end

return PilesReplicator