local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Template = require(script.Parent.CustomPromptTemplate)

local localPlayer = game:GetService("Players").LocalPlayer

local BrainrotPrompt = {}

function BrainrotPrompt:OnUsed(prompt: ProximityPrompt)
    local ownerId = prompt:GetAttribute("OwnerId")

	if ownerId ~= localPlayer.UserId then return end

	self._brainrotController:StartJump()
end

function BrainrotPrompt.new(controllers)
	local self = setmetatable(BrainrotPrompt, {__index = Template})
	self._gui = ReplicatedStorage.Assets.UI.Prompts[script.Name]
	self._buttonsInteractionsConnector = controllers.ButtonsInteractionsConnector
	self._brainrotController = controllers.BrainrotController
	self._inputController = controllers.InputController
	self._guiController = controllers.GuiController
	self._inputConnections = {}
	self._guiPerPrompt = {}

	return self
end

return BrainrotPrompt