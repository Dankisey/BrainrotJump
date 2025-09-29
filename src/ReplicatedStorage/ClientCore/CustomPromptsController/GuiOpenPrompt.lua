local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Template = require(script.Parent.CustomPromptTemplate)

local GuiOpenPrompt = {}

function GuiOpenPrompt:OnUsed(prompt: ProximityPrompt)
    local guiName = prompt:GetAttribute("GuiName")

	self._guiController[guiName]:Enable(true)

	if guiName == "PetIndex" then
    	self._controllers.GuiController.PetsGui.PetsFrame:ChangeCategory("Pet Index")
	end

	if guiName == "SacksGui" and self._tutorialController.CurrentStep == 3 then
		self._tutorialController:CompleteStep()
	end
end

function GuiOpenPrompt.new(controllers)
	local self = setmetatable(GuiOpenPrompt, {__index = Template})
	self._gui = ReplicatedStorage.Assets.UI.Prompts[script.Name]
	self._buttonsInteractionsConnector = controllers.ButtonsInteractionsConnector
	self._tutorialController = controllers.TutorialController
	self._inputController = controllers.InputController
	self._guiController = controllers.GuiController
	self._inputConnections = {}
	self._guiPerPrompt = {}

	return self
end

return GuiOpenPrompt