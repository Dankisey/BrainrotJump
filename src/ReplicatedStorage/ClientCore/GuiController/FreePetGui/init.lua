local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiTemplate = require(ReplicatedStorage.Modules.UI.AnimatedGuiTemplate)

local FreePetGui = {}

function FreePetGui.new()
	local self = setmetatable(FreePetGui, {__index = GuiTemplate})

	self:CreateChildren(script.Name, script:GetChildren())

	return self
end

return FreePetGui