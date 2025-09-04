local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)
local SaveTemplate = require(script.SaveTemplate)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EggConfig = require(ReplicatedStorage.Configs.EggConfig)
local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)
local PetIndexConfig = require(ReplicatedStorage.Configs.PetIndexConfig)

local Remotes = ReplicatedStorage.Remotes.Pets

local PetIndexRewardRequested = Remotes.PetIndexRewardRequested
local PetIndexRewardGranted = Remotes.PetIndexRewardGranted
local PetIndexUpdated = Remotes.PetIndexUpdated
local PetIndexSaveLoaded = Remotes.PetIndexSaveLoaded
local GetPetIndexSave = Remotes.GetPetIndexSave

local PetIndexService = {}

function PetIndexService:AddPet(player, petName, petRank)
    if self._playerSaves[player].PetsCollected[petRank][petName] then return end

    self._playerSaves[player].PetsCollected[petRank][petName] = true

    PetIndexUpdated:FireClient(player, petName, petRank)
end

function PetIndexService:TryGiveReward(player, forEgg, forRank, info)
    if self._debounces[player] then return end

    self._debounces[player] = true
    local reward

    task.spawn(function()
        task.wait(3)
        self._debounces[player] = false
    end)

    if forEgg then
        if self._playerSaves[player].RewardsGranted.ForEgg[info.EggName][info.Rank] then
            print("Already collected")
            return
        end

        local pets = EggConfig[info.EggName].Pets

        for petName, _ in pets do
            if not self._playerSaves[player].PetsCollected[info.Rank][petName] then return end
        end

        reward = PetIndexConfig.ForEgg[info.EggName][info.Rank]
    elseif forRank then
        if self._playerSaves[player].RewardsGranted.ForRank[info] then return end

        if #self._utils.GetKeys(self._playerSaves[player].PetsCollected[info]) ~= self._totalPets then return end

        reward = PetIndexConfig.ForRank[info]
    end

    self._services.RewardService:GiveReward(player, {FunctionName = reward.RewardName, Data = reward.Data})
    PetIndexRewardGranted:FireClient(player, forEgg, forRank, info)

    if forEgg then
        self._playerSaves[player].RewardsGranted.ForEgg[info.EggName][info.Rank] = true
    elseif forRank then
        self._playerSaves[player].RewardsGranted.ForRank[info] = true
    end
end

function PetIndexService:UnloadSave(player: Player)
    local save = self._playerSaves[player]
    self._playerSaves[player] = nil

    return save
end

function PetIndexService:LoadSave(player: Player, savedData: {}?)
    if not savedData then
        savedData = self._utils.DeepCopy(SaveTemplate)
    end

    self._playerSaves[player] = savedData
    PetIndexSaveLoaded:FireClient(player, savedData)
end

function PetIndexService:Initialize()
    GetPetIndexSave.OnServerInvoke = function(player)
        while not self._playerSaves[player] do
            task.wait()
        end

        return self._playerSaves[player]
    end

    PetIndexRewardRequested.OnServerEvent:Connect(function(player, forEgg, forRank, info)
        self:TryGiveReward(player, forEgg, forRank, info)
    end)

    self._totalPets = #self._utils.GetKeys(PetsConfig.Pets)
    self._debounces = {}
end

function PetIndexService:InjectUtils(utils)
    self._utils = utils
end

function PetIndexService.new()
    local self = setmetatable(PetIndexService, {__index = ServiceTemplate})
    self._playerSaves = {}

    return self
end

return PetIndexService