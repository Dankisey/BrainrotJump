local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Upgrades
local PurchaseAttempted = Remotes.PurchaseAttempted

local UpgradesConfig = require(ReplicatedStorage.Configs.UpgradesConfig)

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)
local ServerTypes = require(script.Parent.Parent.ServerTypes)

local Players = game:GetService("Players")

local UpgradesService = {} :: ServerTypes.UpgradesService

local function updateAttributeValue(player: Player, upgradeName: string, upgradeLevel: number)
    local attributeName = UpgradesConfig.AttributeBasedUpgrades[upgradeName]

    if not attributeName then return end

    player:SetAttribute(attributeName, UpgradesConfig.Upgrades[upgradeName].Levels[upgradeLevel].Value)
end

local function onPlayerAdded(player: Player)
    local upgradesFolder = player:WaitForChild("Upgrades") :: Folder

    for upgradeName, _ in pairs(UpgradesConfig.AttributeBasedUpgrades) do
        local levelValueObject = upgradesFolder:WaitForChild(UpgradesConfig.Upgrades[upgradeName].LevelObjectName)
        updateAttributeValue(player, upgradeName, levelValueObject.Value)
    end
end

function UpgradesService:TryGetLevel(player: Player, upgradeName: string)
    if not UpgradesConfig.Upgrades[upgradeName] then return end

    local levelObject = player.Upgrades:FindFirstChild(UpgradesConfig.Upgrades[upgradeName].LevelObjectName)

    if not levelObject then return end

    return levelObject.Value
end

function UpgradesService:TryGetBonus(player: Player, upgradeName: string)
    local level = self:TryGetLevel(player, upgradeName)

    if not level then return end

    return UpgradesConfig.Upgrades[upgradeName].Levels[level].Value or UpgradesConfig.Upgrades[upgradeName].Levels[level]
end

function UpgradesService:Initialize()
    Players.PlayerAdded:Connect(onPlayerAdded)

    for _, player: Player in pairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end

    PurchaseAttempted.OnServerEvent:Connect(function(player: Player, upgradeName: string)
        if self._debounces[player] then return end

        self._debounces[player] = true

        task.delay(.5, function()
            self._debounces[player] = nil
        end)

        local upgrade = UpgradesConfig.Upgrades[upgradeName]

        if not upgrade then return end

        local levelValueObject = player.Upgrades[UpgradesConfig.Upgrades[upgradeName].LevelObjectName]

        if levelValueObject.Value >= #UpgradesConfig.Upgrades[upgradeName].Levels then
            return self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "Upgrade is Already on Max Level")
        end

        local worldLock = #UpgradesConfig.Upgrades[upgradeName].Levels[levelValueObject.Value + 1].WorldLock

        if worldLock and (not self._services.WorldsService:IsWorldUnlocked(player, worldLock))then
            return self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "Upgrade is not available yet")
        end

        if self._services.SoftCurrencyService:TrySpentCurrency(player, "UpgradePoints", 1, "Gameplay", upgradeName) then
            levelValueObject.Value += 1

            if UpgradesConfig.AttributeBasedUpgrades[upgradeName] then
                updateAttributeValue(player, upgradeName, levelValueObject.Value)
            end

            self._services.ServerMessagesSender:SendMessageToPlayer(player, "Congrats", string.format("%s is Successfully Upgraded", UpgradesConfig.Upgrades[upgradeName].PublicName))
        else
            self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "Level Up your Brainrot to get Upgrade Points!")
        end
    end)
end

function UpgradesService.new()
    local self = setmetatable(UpgradesService, {__index = ServiceTemplate})
    self._debounces = {}

    return self
end

return UpgradesService