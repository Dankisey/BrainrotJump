local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)
local GenerateViewport = require(ReplicatedStorage.Modules.UI.GenerateViewport)
local Remotes = ReplicatedStorage.Remotes.Pets
local DeletePetAttempted = Remotes.DeletePetAttempted
local EquipPetAttempted = Remotes.EquipPetAttempted
local UpgradePetAttempted = Remotes.UpgradePetAttempted
local GamepassRequested = ReplicatedStorage.Remotes.Monetization.GamepassRequested
local GamepassesConfig = require(ReplicatedStorage.Configs.GamepassesConfig)
local GetKeys = require(ReplicatedStorage.Modules.Utils.GetKeys)

local PetsInventory = {}

local RarityToIndex = {
    ["Divine"] = 6;
    ["Mythical"] = 5;
    ["Legendary"] = 4;
    ["Rare"] = 3;
    ["Uncommon"] = 2;
    ["Common"] = 1;
}

local function countPetsOfType(self, petName, isGold)
    local counter = 0

    for _, petData in self._playerPets do
        if petData.ConfigName == petName and petData.IsGold == isGold and petData.IsShiny == false then
            counter += 1
        end
    end

    return counter
end

local function generateViewportFrame(Viewport : ViewportFrame,PetModel: Model)
	GenerateViewport:GenerateViewport(Viewport,PetModel)
end

local function toggleEquipButton(self, isEquipped)
    if isEquipped then
        self._equipButton.TextLabel.Text = "Unequip"
        self._equipButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    else
        self._equipButton.TextLabel.Text = "Equip"
        self._equipButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    end
end

local function initialize(self)
    self._chosenPet = nil
    self._deleteMode = false
    self._itemTemplate = self._frame.Grid.ItemTemplate
    self._descriptionFrame = self._frame.Description

    local buttons = self._descriptionFrame.Buttons
    self._deleteButton = buttons.Delete
    self._equipButton = buttons.Equip
    self._goldButton = buttons.Gold

    self._buttons = {
        Delete = buttons.Delete;
        Equip = buttons.Equip;
        Gold = buttons.Gold;
    }

    self._confirmationPromptText = "Are you sure you want to delete the pet?"
    self._deleteDeclineCallback = function()
    end

    self._multiplierCoinsFrame = self._descriptionFrame.MultiplierCoins
    self._multiplierPowerFrame = self._descriptionFrame.MultiplierPower

    self._bottom = self._frame.Bottom
    self._deleteBottom = self._frame.DeleteBottom

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._bottom.DeleteMode.TextButton, function()
        self:ToggleDeleteMode(true)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._deleteBottom.Cancel.ImageButton, function()
        self:ToggleDeleteMode(false)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._deleteBottom.Confirm.ImageButton, function()
        local petsToDelete = {}

	    for key, petFrame in pairs(self._petsCollection) do
		    if 	petFrame.InteractionButton.X.Visible then
			    table.insert(petsToDelete, key)
		    end
	    end

	    DeletePetAttempted:FireServer(petsToDelete)
	    self:ToggleDeleteMode()
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._bottom.EquipBest.Button, function()
        if self._controllers.TutorialController.CurrentStep == 11 then
            self._controllers.TutorialController:CompleteStep()
        end

        local maxEquippedPets = self._player:GetAttribute("MaxEquippedPets") or PetsConfig.ServiceData.MaxEquippedPets
        local currentEquippedPets = self:GetEquippedPets()

        if currentEquippedPets then
            for key, _ in currentEquippedPets do
                EquipPetAttempted:FireServer(key)
            end
        end

        if not self._sortedPetKeys then return end

        task.wait(.5)

        for i = 1, tonumber(maxEquippedPets) do
            local key = self._sortedPetKeys[i]

            if not self._playerPets[key] then break end
            if self._playerPets[key].IsEquipped then continue end

            EquipPetAttempted:FireServer(key)
        end
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._bottom.Stats.Equipped.ImageButton, function()
        GamepassRequested:FireServer(GamepassesConfig.Attributes.Plus1Pet.GamepassId)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._bottom.Stats.Storage.ImageButton, function()
        if self._player:GetAttribute(GamepassesConfig.Attributes.Plus50Storage.AttributeName) then
            GamepassRequested:FireServer(GamepassesConfig.Attributes.Plus100Storage.GamepassId)
        else
            GamepassRequested:FireServer(GamepassesConfig.Attributes.Plus50Storage.GamepassId)
        end
    end)

    self._petsCollection = {}

    for key: string, petData: PetsConfig.PetData in pairs(self._playerPets) do
        self:CreateNewPet(key, petData)
    end

    local deleteConfirmCallback = function()
        DeletePetAttempted:FireServer({self._chosenPet})
    end

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._deleteButton, function()
        self._controllers.GuiController.ConfirmationPromptGui:ShowPrompt(self._confirmationPromptText, 
                                                                            deleteConfirmCallback, self._deleteDeclineCallback)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._equipButton, function()
        EquipPetAttempted:FireServer(self._chosenPet)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._goldButton, function()
        UpgradePetAttempted:FireServer(self._chosenPet)
    end)

    self._descriptionFrame.Visible = false
end

function PetsInventory:GetEquippedPets()
	local equippedPetList = {}

	for key, petData in pairs(self._playerPets) do
		if petData.IsEquipped then
			equippedPetList[key] = petData
		end
	end

	return equippedPetList
end

function PetsInventory:ToggleDeleteMode(on: boolean)
	local value = on or not self._deleteMode

	self._deleteMode = value

	if value then
        for _, petFrame in pairs(self._petsCollection) do
		    petFrame.Selected.Visible = false
	    end
	else
        for _, petFrame in pairs(self._petsCollection) do
		    petFrame.InteractionButton.X.Visible = false
	    end
	end

    self._bottom.Visible = not value
    self._deleteBottom.Visible = value
end

function PetsInventory:UpdateStats(player)
    local equippedPets = self:GetEquippedPets()
    self._bottom.Stats.Equipped.TextLabel.Text = #GetKeys(equippedPets) .. "/" .. player:GetAttribute("MaxEquippedPets")
    self._bottom.Stats.Storage.TextLabel.Text = #GetKeys(self._playerPets) .. "/" .. player:GetAttribute("MaxStorageSpace")
end

function PetsInventory:SortPets()
    self._sortedPetKeys = GetKeys(self._playerPets)

    if #self._sortedPetKeys < 2 then return end

    table.sort(self._sortedPetKeys, function(a, b)
        local aData = self._playerPets[a]
        local bData = self._playerPets[b]
        local powerMultiplierA = PetsConfig.Pets[aData.ConfigName].WinsMultiplier
        local powerMultiplierB = PetsConfig.Pets[bData.ConfigName].WinsMultiplier
        local coinsA = PetsConfig.Pets[aData.ConfigName].CashMultiplier
        local coinsB = PetsConfig.Pets[bData.ConfigName].CashMultiplier

        if aData.IsGold then
            powerMultiplierA *= PetsConfig.Pets[aData.ConfigName].GoldStatsMultiplier
            coinsA *= PetsConfig.Pets[aData.ConfigName].GoldStatsMultiplier
        elseif aData.IsShiny then
            powerMultiplierA *= PetsConfig.Pets[aData.ConfigName].ShinyStatsMultiplier
            coinsA *= PetsConfig.Pets[aData.ConfigName].ShinyStatsMultiplier
        end

        if bData.IsGold then
            powerMultiplierB *= PetsConfig.Pets[bData.ConfigName].GoldStatsMultiplier
            coinsB *= PetsConfig.Pets[bData.ConfigName].GoldStatsMultiplier
        elseif bData.IsShiny then
            powerMultiplierB *= PetsConfig.Pets[bData.ConfigName].ShinyStatsMultiplier
            coinsB *= PetsConfig.Pets[bData.ConfigName].ShinyStatsMultiplier
        end

        if powerMultiplierA ~= powerMultiplierB then
            return powerMultiplierA > powerMultiplierB
        elseif coinsA ~= coinsB then
            return coinsA > coinsB
        elseif RarityToIndex[PetsConfig.Pets[aData.ConfigName].Rarity] ~= RarityToIndex[PetsConfig.Pets[bData.ConfigName].Rarity] then
            return RarityToIndex[PetsConfig.Pets[aData.ConfigName].Rarity] > RarityToIndex[PetsConfig.Pets[bData.ConfigName].Rarity]
        else
            return powerMultiplierA > powerMultiplierB
        end
    end)

    for i, key in ipairs(self._sortedPetKeys) do
        if not self._petsCollection[key] then continue end
        self._petsCollection[key].LayoutOrder = i
    end
end

function PetsInventory:ShowDescription(key, petData)
    if self._chosenPet then
        self._previousChosen = self._chosenPet

        if self._petsCollection[self._previousChosen] then
            self._petsCollection[self._previousChosen].Selected.Visible = false
        end
    end

    self._petsCollection[key].Selected.Visible = true
    self._chosenPet = key
    self._descriptionFrame.Visible = true

    -- for _, button in self._buttons do
    --     self._controllers.ButtonsInteractionsConnector:DisconnectButton(button)
    -- end

    local PetModel = PetsConfig.Pets[petData.ConfigName].Model

	if PetModel then
		generateViewportFrame(self._descriptionFrame.ViewportFrame, PetModel:Clone())
	end

    local name = petData.ConfigName
    local coinsMultiplier = PetsConfig.Pets[petData.ConfigName].CashMultiplier
    local powerMultiplier = PetsConfig.Pets[petData.ConfigName].WinsMultiplier

    if petData.IsGold then
        name = name .. " Gold"
        coinsMultiplier *= PetsConfig.Pets[petData.ConfigName].GoldStatsMultiplier
        powerMultiplier *= PetsConfig.Pets[petData.ConfigName].GoldStatsMultiplier
        self._descriptionFrame.ItemName.TextColor3 = PetsConfig.TextColors.Gold
        self._goldButton.Visible = true
    elseif petData.IsShiny then
        name = name .. " Shiny"
        coinsMultiplier *= PetsConfig.Pets[petData.ConfigName].ShinyStatsMultiplier
        powerMultiplier *= PetsConfig.Pets[petData.ConfigName].ShinyStatsMultiplier
        self._descriptionFrame.ItemName.TextColor3 = PetsConfig.TextColors.Shiny
        self._goldButton.Visible = false
    else
        self._descriptionFrame.ItemName.TextColor3 = PetsConfig.TextColors.Normal
        self._goldButton.Visible = true
    end

    self._descriptionFrame.ItemName.Text = name
    self._descriptionFrame.Rarity.Text = PetsConfig.Pets[petData.ConfigName].Rarity
    local rarityColor = PetsConfig.RarityColors[PetsConfig.Pets[petData.ConfigName].Rarity]
    self._descriptionFrame.Background.BackgroundColor3 = rarityColor
    self._multiplierCoinsFrame.TextLabel.Text = "x" .. string.format("%.1f", coinsMultiplier)
    self._multiplierPowerFrame.TextLabel.Text = "x" .. string.format("%.1f", powerMultiplier)

    if self._goldButton.Visible then
        local currentPetCount = countPetsOfType(self, petData.ConfigName, petData.IsGold)

        if petData.IsGold then
            self._goldButton.TextLabel.Text = "Shiny " .. currentPetCount .. "/" .. PetsConfig.Pets[petData.ConfigName].PetsToCraftShiny
        else
            self._goldButton.TextLabel.Text = "Gold " .. currentPetCount .. "/" .. PetsConfig.Pets[petData.ConfigName].PetsToCraftGold
        end
    end

    toggleEquipButton(self, petData.IsEquipped)
end

function PetsInventory:UpdateIconColor()
    self._icon.ImageColor3 = if self._boolValue.Value then Color3.new(1, 1, 1) else Color3.new(0, 0, 0)
end

function PetsInventory:ChangeStatus(key, petData)
    -- equip-unequip
    self._playerPets[key] = petData

    self._petsCollection[key].EquippedMark.Visible = petData.IsEquipped

    if self._chosenPet == key then
        toggleEquipButton(self, petData.IsEquipped)
    end
end

function PetsInventory:CreateNewPet(key, petData)
    if self._petsCollection[key] then return end
    self._playerPets[key] = petData

    local newPet = self._itemTemplate:Clone()
    newPet.Parent = self._frame.Grid

	local rarityColor =  PetsConfig.RarityColors[PetsConfig.Pets[petData.ConfigName].Rarity]
	local PetModel = PetsConfig.Pets[petData.ConfigName].Model

	if PetModel then
		generateViewportFrame(newPet.ViewportFrame, PetModel:Clone())
	end

    local name = petData.ConfigName

    if petData.IsGold then
        name = name .. " Gold"
        newPet.ItemName.TextColor3 = PetsConfig.TextColors.Gold
    elseif petData.IsShiny then
        name = name .. " Shiny"
        newPet.ItemName.TextColor3 = PetsConfig.TextColors.Shiny
    else
        newPet.ItemName.TextColor3 = PetsConfig.TextColors.Normal
    end

    self._descriptionFrame.ItemName.Text = name

	newPet.Background.BackgroundColor3 = rarityColor
    newPet.ItemName.Text = name
    newPet.EquippedMark.Visible = petData.IsEquipped
    newPet.Visible = true

    self._petsCollection[key] = newPet

    local interactionButton = newPet.InteractionButton

    local function interactionButtonCallback()
		if not self._deleteMode then
			self:ShowDescription(key, self._playerPets[key])
		else
			interactionButton.X.Visible = not interactionButton.X.Visible
		end
    end

    self._controllers.ButtonsInteractionsConnector:ConnectButton(interactionButton, interactionButtonCallback)

    self._controllers.TooltipsController:RegisterPetTooltip(newPet, petData.ConfigName, petData.IsGold, petData.IsShiny)

    self:SortPets()
end

function PetsInventory:DeletePet(key)
    self._petsCollection[key]:Destroy()
    self._petsCollection[key] = nil
    self._playerPets[key] = nil
    self._descriptionFrame.Visible = false
    self:SortPets()
end

function PetsInventory:TurnOn()
    self._frame.Visible = true
end

function PetsInventory:TurnOff()
    self._frame.Visible = false
end

function PetsInventory.new(frame: Frame, controllers, playerPets, player)
    local self = setmetatable({}, {__index = PetsInventory})
    self._controllers = controllers
    self._frame = frame
    self._playerPets = playerPets
    self._player = player
    initialize(self)

    return self
end

return PetsInventory