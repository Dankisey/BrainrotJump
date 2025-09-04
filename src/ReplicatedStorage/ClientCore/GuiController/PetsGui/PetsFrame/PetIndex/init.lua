local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)
local EggConfig = require(ReplicatedStorage.Configs.EggConfig)
local PetIndexConfig = require(ReplicatedStorage.Configs.PetIndexConfig)
local PetIndexRewardRequested = ReplicatedStorage.Remotes.Pets.PetIndexRewardRequested
local PetIndexRewardGranted = ReplicatedStorage.Remotes.Pets.PetIndexRewardGranted
local PetIndexUpdated = ReplicatedStorage.Remotes.Pets.PetIndexUpdated
local PetIndexSaveLoaded = ReplicatedStorage.Remotes.Pets.PetIndexSaveLoaded
local GetPetIndexSave = ReplicatedStorage.Remotes.Pets.GetPetIndexSave
local GetKeys = require(ReplicatedStorage.Modules.Utils.GetKeys)
local InfoPin = require(ReplicatedStorage.Modules.UI.InfoPin)

local EggFrame = require(script.EggFrame)

local PetIndex = {}

local function onSaveLoaded(self, petData)
    for rank, pets in petData.PetsCollected do
        for petName, _ in pets do
            for _, eggFrame in self._eggFrames do
                eggFrame:UnlockPet(petName, rank)
            end
        end
    end

    for eggName, eggFrame in self._eggFrames do
        eggFrame:ChangeRank("Normal")

        for rank, _ in petData.RewardsGranted.ForEgg[eggName] do
            eggFrame:OnRewardGranted(rank)
        end
    end

    for rank, _ in petData.RewardsGranted.ForRank do
        self._ranksFrame.Ranks[rank].Reward.Received.Visible = true
        self._controllers.ButtonsInteractionsConnector:DisconnectButton(self._ranksFrame.Ranks[rank].Reward.ImageButton)
    end

    self:UpdateRankCounters(petData.PetsCollected)
end

local function createEggFrames(self)
    self._eggFrames = {}

    for eggName, eggData in EggConfig do
        local template = self._grid.ItemTemplate:Clone() :: Frame
        self._eggFrames[eggName] = EggFrame.new(template, eggName, self._controllers, self._utils, self)
        template.Parent = self._grid
        template.LayoutOrder = eggData.World
        template.Visible = true
        template.Name = eggName
    end
end

local function initialize(self)
    createEggFrames(self)

    self._infoPins = {}

    self._controllers.EggsController.EggUnlocked:Subscribe(self, function(eggName)
        self:UnlockEgg(eggName)
    end)

    PetIndexUpdated.OnClientEvent:Connect(function(petName, petRank)
        for eggName, eggFrame in self._eggFrames do
            eggFrame:UnlockPet(petName, petRank)
        end

        local petData = GetPetIndexSave:InvokeServer()
        self:UpdateRankCounters(petData.PetsCollected)
    end)

    PetIndexSaveLoaded.OnClientEvent:Connect(function(petsData)
        onSaveLoaded(self, petsData)
    end)

    self._rewardRankButtons = {}
    local changeRankFrames = self._ranksFrame.Ranks
    self._totalPetsCount = #GetKeys(PetsConfig.Pets)

    for _, frame in changeRankFrames:GetChildren() do
        if not frame:IsA("Frame") then continue end

        frame.ChangeButton.Counter.Text = "/" .. self._totalPetsCount
        local rank = frame.Name
        frame.Reward.Reward.Text = PetIndexConfig.ForRank[rank].RewardName
        frame.Reward.ImageLabel.Image = PetIndexConfig.ForRank[rank].Icon
        frame.Reward.Quantity.Text = "x" .. PetIndexConfig.ForRank[rank].Amount
        self._infoPins[rank] = InfoPin.new(frame.Reward.InfoPin)

        self._controllers.ButtonsInteractionsConnector:ConnectButton(frame.ChangeButton, function()
            for _, eggFrame in self._eggFrames do
                eggFrame:ChangeRank(rank)
            end
        end)

        self._rewardRankButtons[rank] = frame.Reward.ImageButton

        self._controllers.ButtonsInteractionsConnector:ConnectButton(frame.Reward.ImageButton, function()
            PetIndexRewardRequested:FireServer(false, true, rank)
        end)
    end

    PetIndexRewardGranted.OnClientEvent:Connect(function(forEgg, forRank, info)
        if forEgg then
            self._eggFrames[info.EggName]:OnRewardGranted(info.Rank)
        elseif forRank then
            local rank = info
            self._infoPins[rank]:TurnOff()
            changeRankFrames[rank].Reward.Received.Visible = true
            self._controllers.ButtonsInteractionsConnector:DisconnectButton(changeRankFrames[rank].Reward.ImageButton)
        end

        local canDisableCommonInfopins = true

        for _, infopin in self._infoPins do
            canDisableCommonInfopins = not infopin:IsEnabled()
            if canDisableCommonInfopins == false then break end
        end

        if not canDisableCommonInfopins then return end

        local shouldBreak = false
        for _, eggFrame in self._eggFrames do
            for _, infopin in eggFrame.EggInfoPins do
                canDisableCommonInfopins = not infopin:IsEnabled()

                if not canDisableCommonInfopins then
                    shouldBreak = true
                    break
                end
            end
            if shouldBreak then break end
        end

        if canDisableCommonInfopins then
            self._controllers.GuiController.PetsGui.PetsFrame.IndexInfoPin:TurnOff()
            self._controllers.GuiController.MainGui.LeftSide.PetIndexInfoPin:TurnOff()
        end
    end)
end

function PetIndex:UpdateRankCounters(petData)
    for rank, pets in petData do
        local playersCount = #GetKeys(pets)
        self._ranksFrame.Ranks[rank].ChangeButton.Counter.Text = playersCount .. "/" .. self._totalPetsCount

        if playersCount == self._totalPetsCount then
            self._infoPins[rank]:TurnOn()
            self._controllers.GuiController.PetsGui.PetsFrame.IndexInfoPin:TurnOn()
            self._controllers.GuiController.MainGui.LeftSide.PetIndexInfoPin:TurnOn()
        end
    end
end

function PetIndex:UnlockEgg(eggName)
    self._eggFrames[eggName]:Unlock()
end

function PetIndex:TurnOn()
    self._frame.Visible = true
end

function PetIndex:TurnOff()
    self._frame.Visible = false
end

function PetIndex.new(frame: Frame, controllers, playerPets)
    local self = setmetatable({}, {__index = PetIndex})
    self._controllers = controllers
    self._frame = frame
    self._playerPets = playerPets
    self._grid = frame.Content
    self._ranksFrame = frame.RanksFrame
    initialize(self)

    return self
end

return PetIndex