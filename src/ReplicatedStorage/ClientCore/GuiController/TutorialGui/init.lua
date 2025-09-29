local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiTemplate = require(ReplicatedStorage.Modules.UI.GuiTemplate)

local TutorialGui = {}

function TutorialGui.new()
	local self = setmetatable(TutorialGui, {__index = GuiTemplate})

	self:CreateChildren(script.Name, script:GetChildren())

	return self
end

return TutorialGui