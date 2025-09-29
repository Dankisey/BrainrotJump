local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)
local InfoPin = require(ReplicatedStorage.Modules.UI.InfoPin)

local Remotes = ReplicatedStorage.Remotes.Pets
local GetPlayerPets = Remotes.GetPlayerPets :: RemoteFunction
local PetReceived = Remotes.PetReceived :: RemoteEvent
local PetAdded = Remotes.PetAdded :: RemoteEvent
local PetRemoved = Remotes.PetRemoved :: RemoteEvent
local PetDeleted = Remotes.PetDeleted :: RemoteEvent
local GamepassPurchased = ReplicatedStorage.Remotes.Monetization.GamepassPurchased :: RemoteEvent

local PetsInventoryTemplate = require(script.PetsInventory)
local PetIndexTemplate = require(script.PetIndex)

local PetsFrame = {}

function PetsFrame:Disable()
    self._frame.Visible = false
end

function PetsFrame:Enable()
    self._frame.Visible = true
end

function PetsFrame:ChangeCategory(category)
    if category == "Pet Index" then
        self._petsInventoryFrame:TurnOff()
	    self._petIndexFrame:TurnOn()
    elseif category == "Pets" then
        self._petIndexFrame:TurnOff()
		self._petsInventoryFrame:TurnOn()
    end

    self._frame.TopBar.TextLabel.Text = category
end

function PetsFrame:AfterPlayerLoaded(player: Player)
    self._localPlayer = player

    task.wait(1)
    self._playerPets = GetPlayerPets:InvokeServer()

    self._petsInventoryFrame = PetsInventoryTemplate.new(self._frame.Categories.PetsInventory, self._controllers, self._playerPets, player)
    self._petIndexFrame = PetIndexTemplate.new(self._frame.Categories.PetIndex, self._controllers, self._playerPets)

    self._petsInventoryFrame:UpdateStats(player)

    local sideButtons = self._frame.SideButtons

    self._indexButton = sideButtons.Index

    self.IndexInfoPin = InfoPin.new(self._indexButton.InfoPin)

    local function indexButtonCallback()
        self:ChangeCategory("Pet Index")
	end

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._indexButton, indexButtonCallback)

    self._petsInventoryButton = sideButtons.Pets

    local function petsInventoryButtonCallback()
        self:ChangeCategory("Pets")
	end

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._petsInventoryButton, petsInventoryButtonCallback)

    PetReceived.OnClientEvent:Connect(function(key, petData)
        self._petsInventoryFrame:CreateNewPet(key, petData)
        self._petsInventoryFrame:UpdateStats(player)
    end)

    PetAdded.OnClientEvent:Connect(function(playerWithEvent, key, petData)
        if playerWithEvent ~= self._localPlayer then return end

        self._playerPets[key] = petData
        self._petsInventoryFrame:ChangeStatus(key, petData)
        self._petsInventoryFrame:UpdateStats(player)
    end)

    PetRemoved.OnClientEvent:Connect(function(playerWithEvent, key)
        if playerWithEvent ~= self._localPlayer then return end

        self._playerPets[key].IsEquipped = false

        self._petsInventoryFrame:ChangeStatus(key, self._playerPets[key])
        self._petsInventoryFrame:UpdateStats(player)
    end)

    PetDeleted.OnClientEvent:Connect(function(key)
        self._petsInventoryFrame:DeletePet(key)
        self._petsInventoryFrame:UpdateStats(player)
    end)

    GamepassPurchased.OnClientEvent:Connect(function(attributeName)
        if table.find(self._configs.GamepassesConfig.AttributesWithExtraFunctions, attributeName) then
            self._petsInventoryFrame:UpdateStats(player)
        end
    end)
end

function PetsFrame:Initialize()
    self._closeButton = self._frame.CloseButton

	local function closeGui()
        if self._controllers.TutorialController.CurrentStep == 12 then
            self._controllers.TutorialController:CompleteStep()
        end

		self._controllers.GuiController.PetsGui:Disable()
	end

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._closeButton, closeGui)
end

function PetsFrame.new(frame: Frame)
    local self = setmetatable(PetsFrame, {__index = ControllerTemplate})
    self._frame = frame

    return self
end

return PetsFrame