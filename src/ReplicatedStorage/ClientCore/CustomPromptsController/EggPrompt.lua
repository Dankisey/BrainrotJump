local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local DevProductRequested = Remotes.Monetization.DevProductRequested
local GamepassRequested = Remotes.Monetization.GamepassRequested
local EggHatchRequested = Remotes.Eggs.EggHatchRequested
local AutoStopRequested = Remotes.Eggs.AutoStopRequested

local LocalPlayer = game:GetService("Players").LocalPlayer
local EggConfig = require(ReplicatedStorage.Configs.EggConfig)
local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)
local GamepassesConfig = require(ReplicatedStorage.Configs.GamepassesConfig)
local GenerateViewport = require(ReplicatedStorage.Modules.UI.GenerateViewport)
local Template = require(script.Parent.EggPromptTemplate)

local EggPrompt = {}

local function generateViewportFrame(Viewport : ViewportFrame,PetModel: Model)
	GenerateViewport:GenerateViewport(Viewport,PetModel)
end

function EggPrompt:OnEnabled(prompt: ProximityPrompt, gui: BillboardGui)
    local EggModel = prompt.Parent.Parent

    self._eggName = EggModel.Name
    self._eggData = EggConfig[EggModel.Name]

    local petTemplate = gui.EggFrame.Top.Pets.ItemTemplate

    for pet, chance in self._eggData.Pets do
        local newPet = petTemplate:Clone()
        newPet.Parent = gui.EggFrame.Top.Pets

	    local rarityColor =  PetsConfig.RarityColors[PetsConfig.Pets[pet].Rarity]
	    local PetModel = PetsConfig.Pets[pet].Model

        if PetModel then
		    generateViewportFrame(newPet.ViewportFrame, PetModel:Clone())
	    end

        newPet.Background.BackgroundColor3 = rarityColor
        newPet.Chance.Text = tostring(chance * 100) .. "%"
        newPet.Visible = true
    end
end

function EggPrompt:OnHatchClicked(_: ProximityPrompt)
    if self._eggData.Currency == "Cash" then
        EggHatchRequested:FireServer(self._eggName, false, false)
    elseif self._eggData.Currency == "Robux" then
        DevProductRequested:FireServer(self._eggData.ProductId)
    end

    if self._eggName == "ButterflyEgg" and self._tutorialController.CurrentStep == 4 then
        self._tutorialController:CompleteStep()
    end
end

function EggPrompt:OnAutoHatchClicked(_: ProximityPrompt)
    if self._eggData.Currency ~= "Cash" then return end

    if LocalPlayer:GetAttribute("IsInAutoHatching") then
        AutoStopRequested:FireServer()
    end

    local hasAutoPass = LocalPlayer:GetAttribute("AutoHatch") or false

    if not hasAutoPass then
        GamepassRequested:FireServer(GamepassesConfig.Attributes.AutoHatch.GamepassId)
    else
        local hasTriplePass = LocalPlayer:GetAttribute("TripleHatch") or false

        EggHatchRequested:FireServer(self._eggName, hasTriplePass, true)
    end
end

function EggPrompt:OnTripleClicked(_: ProximityPrompt)
    if self._eggData.Currency == "Cash" then
        local hasTriplePass = LocalPlayer:GetAttribute("TripleHatch") or false

        if not hasTriplePass then
            GamepassRequested:FireServer(GamepassesConfig.Attributes.TripleHatch.GamepassId)
        else
            EggHatchRequested:FireServer(self._eggName, true, false)
        end
    elseif self._eggData.Currency == "Robux" then
        DevProductRequested:FireServer(self._eggData.ProductIdTriple)
    end
end

function EggPrompt:OnLuckClicked(_: ProximityPrompt)
    local hasLuckPass = LocalPlayer:GetAttribute("Luck") or false

    if not hasLuckPass then
        GamepassRequested:FireServer(GamepassesConfig.Attributes.Luck.GamepassId)
    end
end

function EggPrompt:OnMegaLuckClicked(_: ProximityPrompt)
    local hasMegaLuckPass = LocalPlayer:GetAttribute("MegaLuck") or false

    if not hasMegaLuckPass then
        GamepassRequested:FireServer(GamepassesConfig.Attributes.MegaLuck.GamepassId)
    end
end

function EggPrompt:OnUltraLuckClicked(_: ProximityPrompt)
    local hasUltraLuckPass = LocalPlayer:GetAttribute("UltraLuck") or false

    if not hasUltraLuckPass then
        GamepassRequested:FireServer(GamepassesConfig.Attributes.UltraLuck.GamepassId)
    end
end

function EggPrompt:OnUsed(_: ProximityPrompt)
    self:OnHatchClicked(self)
end

function EggPrompt.new(controllers)
	local self = setmetatable(EggPrompt, {__index = Template})
	self._gui = ReplicatedStorage.Assets.UI.Prompts[script.Name]
    self._customPromptsController = controllers.CustomPromptsController
	self._buttonsInteractionsConnector = controllers.ButtonsInteractionsConnector
    self._encounterController = controllers.EncounterController
    self._tutorialController = controllers.TutorialController
    self._worldsController = controllers.WorldsController
	self._inputController = controllers.InputController
	self._inputConnections = {}
	self._guiPerPrompt = {}

	return self
end

return EggPrompt