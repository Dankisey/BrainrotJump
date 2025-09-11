local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)
local GamepassesConfig = require(ReplicatedStorage.Configs.GamepassesConfig)

local Remotes = ReplicatedStorage.Remotes.Pets
local GetPlayersPets = Remotes.GetPlayersPets :: RemoteFunction
local GetPlayerPets = Remotes.GetPlayerPets :: RemoteFunction
local PetsLoaded = Remotes.PetsLoaded :: RemoteEvent
local PetRemoved = Remotes.PetRemoved :: RemoteEvent
local PetAdded = Remotes.PetAdded :: RemoteEvent
local PetReceived = Remotes.PetReceived :: RemoteEvent
local PetDeleted = Remotes.PetDeleted :: RemoteEvent
local TestGivePets = Remotes.TestGivePets

local DeletePetAttempted = Remotes.DeletePetAttempted :: RemoteEvent
local EquipPetAttempted = Remotes.EquipPetAttempted :: RemoteEvent
local UpgradePetAttempted = Remotes.UpgradePetAttempted :: RemoteEvent

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local PetService = {}

local function collectPetsForCraft(self, player, petName, isGold, petsRequired)
    local counter = 0
    local pets = {}

    for key, petData in self._playerPets[player] do
        if petData.ConfigName == petName and petData.IsGold == isGold and petData.IsShiny == false then
            counter += 1
            table.insert(pets, key)

            if counter >= petsRequired then break end
        end
    end

    return pets
end

local function craftPet(self, player, petName, petsForCrafting, rank)
    for _, key in petsForCrafting do
        self._playerPets[player][key] = nil

        task.spawn(function()
            PetRemoved:FireAllClients(player, key)
            task.wait(.2)
            PetDeleted:FireClient(player, key)
        end)
    end

    self:GivePet(player, petName, rank)
end

function PetService:CountStorageSpaces(player)
    local plus1 = player:GetAttribute(GamepassesConfig.Attributes.Plus1Pet.AttributeName) or false
    local plus4 = player:GetAttribute(GamepassesConfig.Attributes.Plus4Pet.AttributeName) or false
    local plus8 = player:GetAttribute(GamepassesConfig.Attributes.Plus8Pet.AttributeName) or false
    local plus50storage = player:GetAttribute(GamepassesConfig.Attributes.Plus50Storage.AttributeName) or false
    local plus100storage = player:GetAttribute(GamepassesConfig.Attributes.Plus100Storage.AttributeName) or false

    player:SetAttribute("MaxEquippedPets", PetsConfig.ServiceData.MaxEquippedPets)
    player:SetAttribute("MaxStorageSpace", PetsConfig.ServiceData.MaxStorageSpace)

    if plus1 then
        PetService:IncreaseEquippedPets(player, 1)
    end

    if plus4 then
        PetService:IncreaseEquippedPets(player, 4)
    end

    if plus8 then
        PetService:IncreaseEquippedPets(player, 8)
    end

    if plus50storage then
        PetService:IncreaseStorageSpace(player, 50)
    end

    if plus100storage then
        PetService:IncreaseStorageSpace(player, 100)
    end
end

function PetService:CheckAvailableStorage(player, amount)
    local maxStorageForPlayer = player:GetAttribute('MaxStorageSpace') or PetsConfig.ServiceData.MaxStorageSpace

    if #self._utils.GetKeys(self._playerPets[player]) + amount > tonumber(maxStorageForPlayer) then
        self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "You can't receive pets because you are out of storage")
		return false
    else
        return true
	end
end

function PetService:IncreaseEquippedPets(player, quantity)
    local currentMax = player:GetAttribute("MaxEquippedPets") or PetsConfig.ServiceData.MaxEquippedPets
    local newMax = tonumber(currentMax) + quantity
    player:SetAttribute("MaxEquippedPets", newMax)
end

function PetService:IncreaseStorageSpace(player, quantity)
    local currentMax = player:GetAttribute("MaxStorageSpace") or PetsConfig.ServiceData.MaxStorageSpace
    local newMax = tonumber(currentMax) + quantity
    player:SetAttribute("MaxStorageSpace", newMax)
end

function PetService:LoadPets(player: Player, petsInfo: {[string]: PetsConfig.PetData})
    petsInfo = petsInfo or {}

    self._playerPets[player] = petsInfo
    PetsLoaded:FireAllClients(player, petsInfo)
end

function PetService:GivePet(player, petName, rank)
    local rank = rank or "Normal"
    local gold = false
    local shiny = false

    if rank == "Gold" then
        gold = true
    elseif rank == "Shiny" then
        shiny = true
    end

    if not self:CheckAvailableStorage(player, 1) then return false end

    local usedKeys = self._utils.GetKeys(self._playerPets[player])
    local newKey = self._utils.GenerateGuid(usedKeys)

    self._playerPets[player][newKey] = {
        ConfigName = petName;
        IsEquipped = false;
        IsGold = gold;
        IsShiny = shiny;
    }

    PetReceived:FireClient(player, newKey, self._playerPets[player][newKey])
    self._services.PetIndexService:AddPet(player, petName, rank)

    return true
end

function PetService:GetEquippedPets(player)
	local equippedPetList = {}

	for key, petData in pairs(self._playerPets[player]) do
		if petData.IsEquipped then
			equippedPetList[key] = petData
		end
	end

	return equippedPetList
end

function PetService:GetPetsCashMultiplier(player)
    local equippedPets = self:GetEquippedPets(player)
    local cumulativeMutiplier = 1

    for _, petData in equippedPets do
        local multiplier = PetsConfig.Pets[petData.ConfigName].CashMultiplier

        if petData.IsGold then
            multiplier *= PetsConfig.Pets[petData.ConfigName].GoldStatsMultiplier
        elseif petData.IsShiny then
            multiplier *= PetsConfig.Pets[petData.ConfigName].ShinyStatsMultiplier
        end

        cumulativeMutiplier *= multiplier
    end

    return cumulativeMutiplier
end

function PetService:GetPetsWinsMultiplier(player)
    local equippedPets = self:GetEquippedPets(player)
    local cumulativeMutiplier = 1

    for _, petData in equippedPets do
        local multiplier = PetsConfig.Pets[petData.ConfigName].WinsMultiplier

        if petData.IsGold then
            multiplier *= PetsConfig.Pets[petData.ConfigName].GoldStatsMultiplier
        elseif petData.IsShiny then
            multiplier *= PetsConfig.Pets[petData.ConfigName].ShinyStatsMultiplier
        end

        cumulativeMutiplier *= multiplier
    end

    return cumulativeMutiplier
end

function PetService:RemovePlayer(player: Player)
    local petsInfo = self._playerPets[player]
    self._playerPets[player] = nil

    return petsInfo
end

function PetService:Initialize()
    PetRemoved.OnServerEvent:Connect(function(player: Player, key: string)
        if not self._playerPets[player] then
            return warn("Server: Player " .. player.Name .. " is not initialized")
        end

        if not self._playerPets[player][key] then
            return warn("Server: Player " .. player.Name .. " has no pet with key [" .. key .. "]")
        end

        self._playerPets[player][key] = nil
        PetRemoved:FireAllClients(player, key)
    end)

    GetPlayersPets.OnServerInvoke = function(_: Player)
        local playersPets = {}

        for player, v in pairs(self._playerPets) do
            playersPets[player.Name] = table.clone(v)
        end

        return playersPets
    end

    GetPlayerPets.OnServerInvoke = function(player: Player)
        local playerPets = {}
        playerPets = table.clone(self._playerPets[player])

        return playerPets
    end

    EquipPetAttempted.OnServerEvent:Connect(function(player, key)
        if not self._playerPets[player][key] then return end

        if not self._playerPets[player][key].IsEquipped then
            local equippedPets = self:GetEquippedPets(player)
            local maxEquippedForPlayer = player:GetAttribute('MaxEquippedPets') or PetsConfig.ServiceData.MaxEquippedPets

            if #self._utils.GetKeys(equippedPets) + 1 > tonumber(maxEquippedForPlayer) then
		        return
	        end

            self._playerPets[player][key].IsEquipped = true
            PetAdded:FireAllClients(player, key, self._playerPets[player][key])
        else
            self._playerPets[player][key].IsEquipped = false
            PetRemoved:FireAllClients(player, key)
        end
    end)

    DeletePetAttempted.OnServerEvent:Connect(function(player, keys)
        for _, key in keys do
            if not self._playerPets[player][key] then continue end

            self._playerPets[player][key] = nil

            task.spawn(function()
                PetRemoved:FireAllClients(player, key)
                task.wait(.2)
                PetDeleted:FireClient(player, key)
            end)
        end
    end)

    UpgradePetAttempted.OnServerEvent:Connect(function(player, key)
        if not self._playerPets[player][key] then return end
        local petData = self._playerPets[player][key]
        local petsForCrafting = {}

        if petData.IsGold then
            petsForCrafting = collectPetsForCraft(self, player, petData.ConfigName, petData.IsGold, PetsConfig.Pets[petData.ConfigName].PetsToCraftShiny)

            if #petsForCrafting >= PetsConfig.Pets[petData.ConfigName].PetsToCraftShiny then
                craftPet(self, player, petData.ConfigName, petsForCrafting, "Shiny")
            end
        else
            petsForCrafting = collectPetsForCraft(self, player, petData.ConfigName, petData.IsGold, PetsConfig.Pets[petData.ConfigName].PetsToCraftGold)

            if #petsForCrafting >= PetsConfig.Pets[petData.ConfigName].PetsToCraftGold then
                craftPet(self, player, petData.ConfigName, petsForCrafting, "Gold")
            end
        end
    end)

    TestGivePets.OnServerEvent:Connect(function(player)
        -- for key, petData in self._playerPets[player] do
        --     if not self._playerPets[player][key] then continue end

        --     self._playerPets[player][key] = nil

        --     task.spawn(function()
        --         PetRemoved:FireAllClients(player, key)
        --         task.wait(.2)
        --         PetDeleted:FireClient(player, key)
        --     end)
        -- end

        -- self:GivePet(player, "Cat")
        -- self:GivePet(player, "Bunny")
        -- task.spawn(function()
        --     task.wait(20)
        --     self:GivePet(player, "Angel")
        -- end)
    end)
end

function PetService.new()
	local self = setmetatable(PetService, {__index = ServiceTemplate})
    self._playerPets = {} :: {[Player]: {[string]: PetsConfig.PetData}}
    self._playerPetTools = {} :: {[Player]: {[string]: {Name: string, Happiness: number, Active: boolean}}}

	return self
end

return PetService