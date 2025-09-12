local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)
local Remotes = ReplicatedStorage.Remotes.Pets :: Folder
local GetPlayersPets = Remotes.GetPlayersPets :: RemoteFunction
local PetsLoaded = Remotes.PetsLoaded :: RemoteEvent
local PetRemoved = Remotes.PetRemoved :: RemoteEvent
local PetAdded = Remotes.PetAdded :: RemoteEvent
local PetDeleted = Remotes.PetDeleted :: RemoteEvent
local Pet = require(script.Pet)

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local PetsController = {}

local function createPlayerFolder(self, player)
    local playerFolder = Instance.new("Folder")
    playerFolder.Name = player.UserId
    playerFolder.Parent = self._petsFolder
end

local function removeVisual(self, player: Player, key: string)
    if not self._playerPets[player] then
        return
    end

    if not self._playerPets[player][key] then
        return
    end

    self._playerPets[player][key].Visual:Destroy()
    self._playerPets[player][key] = nil
end

local function placeVisual(self, player: Player, newKey: string, petData: PetsConfig.PetData)
    if not self._playerPets[player] then
        self._playerPets[player] = {}
    end

    if self._playerPets[player][newKey] then
        return warn("Player " .. player.Name .. " already has a pet with key [" .. newKey .. "]")
    end

    self._playerPets[player][newKey] = {}
    self._playerPets[player][newKey].Data = petData
    self._playerPets[player][newKey].Visual = Pet.new(petData, newKey, self._player, player, self._petsFolder)
end

function PetsController:RemovePet(key: string)
    PetRemoved:FireServer(key)
end

function PetsController:GetEquippedPets(player)
	local equippedPetList = {}

    if not self._playerPets[player] then
        return
    end

	for key, petData in pairs(self._playerPets[player]) do
		if petData.Data.IsEquipped then
			equippedPetList[key] = petData.Data
		end
	end

	return equippedPetList
end

function PetsController:UpdatePetsMultiplier()
    local equippedPets = self:GetEquippedPets(self._player)
    self._cumulativeMultiplier = 1

    if not equippedPets then
        self.PetsMultiplierChanged:Invoke(self._cumulativeMultiplier)
        return
    end

    for _, petData in equippedPets do
        local name = petData.ConfigName
        local multiplier = PetsConfig.Pets[name].WinsMultiplier

        if petData.IsGold then
            multiplier *= PetsConfig.Pets[name].GoldStatsMultiplier
        elseif petData.IsShiny then
            multiplier *= PetsConfig.Pets[name].ShinyStatsMultiplier
        end

        self._cumulativeMultiplier *= multiplier
    end

    self.PetsMultiplierChanged:Invoke(self._cumulativeMultiplier)
end

function PetsController:GetPetsMultiplier()
    return self._cumulativeMultiplier or 1
end

function PetsController:Initialize(myPlayer: Player)
    self._player = myPlayer
    self._playerPets = {}
    self._cumulativeMultiplier = 1

    local playersPets = GetPlayersPets:InvokeServer() :: {[string]: {[string]: PetsConfig.PetData}}

    self._petsFolder = Instance.new("Folder")
    self._petsFolder.Name = "ClientPets"
    self._petsFolder.Parent = workspace.Game

    for _, player in Players:GetChildren() do
        createPlayerFolder(self, player)
    end

    Players.PlayerAdded:Connect(function(player)
        createPlayerFolder(self, player)
    end)

    if playersPets then
        for playerName: string, petsData: {[string]: PetsConfig.PetData} in pairs(playersPets) do
            local player = Players:FindFirstChild(playerName)

            if not player then continue end

            for key: string, petData: PetsConfig.PetData in pairs(petsData) do
                if not petData.IsEquipped then continue end

                task.spawn(function()
                    local success, value = pcall(placeVisual, self, player, key, petData)

                    if not success then
                        warn("Error occured while creating pet visual:", value)
                    end
                end)
            end
        end
    end

    myPlayer:SetAttribute("IsPetsLoaded", true)

    PetsLoaded.OnClientEvent:Connect(function(player: Player, petsData: {[string]: PetsConfig.PetData})
        for key: string, petData: PetsConfig.PetData in pairs(petsData) do
            if (not self._playerPets[player]) or (not self._playerPets[player][key]) then
                if not petData.IsEquipped then continue end

                task.spawn(function()
                    placeVisual(self, player, key, petData)
                end)
            end
        end

        self:UpdatePetsMultiplier()
    end)

    PetAdded.OnClientEvent:Connect(function(player, ...)
        placeVisual(self, player, ...)

        if player == myPlayer then
            self:UpdatePetsMultiplier()
        end
    end)

    PetRemoved.OnClientEvent:Connect(function(player, ...)
        removeVisual(self, player, ...)

        if player == myPlayer then
            self:UpdatePetsMultiplier()
        end
    end)

    PetDeleted.OnClientEvent:Connect(function(key)
        if self._playerPets[myPlayer] and self._playerPets[myPlayer][key] then
            self._playerPets[myPlayer][key] = nil
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if not self._playerPets[player] then return end

        for key, _ in pairs(self._playerPets[player]) do
            removeVisual(self, player, key)
        end

        self._playerPets[player] = nil

        if self._petsFolder[player.UserId] then
            self._petsFolder[player.UserId]:Destroy()
        end
    end)

    RunService.RenderStepped:Connect(function()
        for _, playerFolder in pairs(self._petsFolder:GetChildren()) do
		    local player = Players:GetPlayerByUserId(playerFolder.Name)

		    if player == nil then continue end

			local character = player.Character

			if character == nil then continue end

            for i, pet in playerFolder:GetChildren() do
                Pet:PositionPet(i, character, pet, playerFolder)
            end
 	    end
    end)
end

function PetsController:InjectUtils(utils)
    self._utils = utils
    self.PetsMultiplierChanged = utils.Event.new()
end

function PetsController.new()
    local self = setmetatable(PetsController, {__index = ControllerTemplate})
    self._playerPets = {} :: {[Player]: {[string]: {Data: PetsConfig.PetData, Visual: Pet.PetClass}}}

    return self
end

return PetsController