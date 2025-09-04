local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EggConfig = require(ReplicatedStorage.Configs.EggConfig)
local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)
local PetIndexConfig = require(ReplicatedStorage.Configs.PetIndexConfig)
local GenerateViewport = require(ReplicatedStorage.Modules.UI.GenerateViewport)
local PetIndexRewardRequested = ReplicatedStorage.Remotes.Pets.PetIndexRewardRequested
local GetPetIndexSave = ReplicatedStorage.Remotes.Pets.GetPetIndexSave
local InfoPin = require(ReplicatedStorage.Modules.UI.InfoPin)

local LocalPlayer = game:GetService("Players").LocalPlayer

local EggFrame = {}

local function generateViewportFrame(Viewport : ViewportFrame,PetModel: Model)
	GenerateViewport:GenerateViewport(Viewport,PetModel)
end

local function initialize(self)
    self._counters = {
        Normal = 0;
        Gold = 0;
        Shiny = 0;
    }
    local config = EggConfig[self._name]
    self.EggInfoPins = {}
    self._isUnlocked = LocalPlayer.Eggs[self._name].Value

    self._eggFrame = self._frame.EggFrame
    self._eggFrame.ItemName.Text = config.PublicName
    self._eggFrame.WorldName.Text = config.World .. " World"
    self._eggFrame.Icon.Image = config.Icon
    self:UpdateIconColor(self._eggFrame.Icon, self._isUnlocked)

    self._petsFrame = self._frame.Pets
    self._rankFrames = {}

    for _, frame in self._petsFrame:GetChildren() do
        local rank = frame.Name
        self._rankFrames[rank] = frame

        local template = frame.PetTemplate
        local counter = 0

        for petName, petChance in config.Pets do
            local newPet = template:Clone()
            newPet.DropChance.Text = tostring(petChance * 100) .. "%"
            newPet.DropChance.Visible = true
            newPet.LayoutOrder = - petChance * 100
            newPet.Name = petName
            local PetModel = PetsConfig.Pets[petName].Model

	        if PetModel then
		        generateViewportFrame(newPet.ViewportFrame, PetModel:Clone())
	        end

            self:UpdateIconColor(newPet.ViewportFrame, false)
            newPet.Parent = frame
            newPet.Visible = true
            counter += 1
        end

        self._totalPetsInEgg = counter

        if counter < 5 then
            while counter < 5 do
                local newPet = template:Clone()
                newPet.Parent = frame
                newPet.LayoutOrder = 100
                newPet.Visible = true
                counter += 1
            end
        end

        local rewardFrame = frame.Reward
        rewardFrame.ImageLabel.Image = PetIndexConfig.ForEgg[self._name][rank].Icon
        rewardFrame.Quantity.Text = "x" .. PetIndexConfig.ForEgg[self._name][rank].Amount
        rewardFrame.Reward.Text = PetIndexConfig.ForEgg[self._name][rank].RewardName
        self.EggInfoPins[rank] = InfoPin.new(rewardFrame.InfoPin)
    end

    if self._isUnlocked then
        self:ConnectRewardButtons()
    end

    self._eggFrame.Counter.Text = "0/" .. self._totalPetsInEgg
end

function EggFrame:ConnectRewardButtons()
    for _, frame in self._petsFrame:GetChildren() do
        local rewardFrame = frame.Reward
        local rank = frame.Name

        self._controllers.ButtonsInteractionsConnector:ConnectButton(rewardFrame.ImageButton, function()
            PetIndexRewardRequested:FireServer(true, false, {EggName = self._name, Rank = rank})
        end)
    end
end

function EggFrame:OnRewardGranted(rank)
    self.EggInfoPins[rank]:TurnOff()
    self._rankFrames[rank].Reward.Received.Visible = true
    self._controllers.ButtonsInteractionsConnector:DisconnectButton(self._rankFrames[rank].Reward.ImageButton)
end

function EggFrame:UpdateIconColor(icon, unlocked)
    icon.ImageColor3 = if unlocked then Color3.new(1, 1, 1) else Color3.new(0, 0, 0)
end

function EggFrame:Unlock()
    if self._isUnlocked then return end

    self._isUnlocked = true

    self:UpdateIconColor(self._frame.EggFrame.Icon, self._isUnlocked)
    self:ConnectRewardButtons()
end

function EggFrame:UnlockPet(petName, petRank)
    local counter = 0

    for _, frame in self._rankFrames[petRank]:GetChildren() do
        if not frame:IsA("Frame") then continue end

        if frame.Name == petName then
            self:UpdateIconColor(frame.ViewportFrame, true)
            self._controllers.TooltipsController:RegisterPetTooltip(frame, petName)
        end

        if frame.ViewportFrame.ImageColor3 == Color3.new(1, 1, 1) then
            counter += 1
        end
    end

    if counter == self._totalPetsInEgg and self._isUnlocked then
        self.EggInfoPins[petRank]:TurnOn()
        self._controllers.GuiController.PetsGui.PetsFrame.IndexInfoPin:TurnOn()
        self._controllers.GuiController.MainGui.LeftSide.PetIndexInfoPin:TurnOn()
    end

    self._counters[petRank] = counter

    if petRank == self._currentRank then
        self._eggFrame.Counter.Text = counter .. "/" .. self._totalPetsInEgg
    end
end

function EggFrame:ChangeRank(rank)
    self._currentRank = rank

    for rankOfFrame, frame in self._rankFrames do
        if rank == rankOfFrame then
            frame.Visible = true
        else
            frame.Visible = false
        end
    end

    self._eggFrame.Counter.Text = self._counters[rank] .. "/" .. self._totalPetsInEgg
end

function EggFrame.new(frame: Frame, name, controllers, utils)
    local self = setmetatable({}, {__index = EggFrame})
    self._controllers = controllers
    self._utils = utils
    self._frame = frame
    self._name = name
    self._currentRank = "Normal"
    initialize(self)

    return self
end

return EggFrame