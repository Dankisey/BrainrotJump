local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiTemplate = require(ReplicatedStorage.Modules.UI.AnimatedGuiTemplate)

local TrailsGui = {}

function TrailsGui.new()
	local self = setmetatable(TrailsGui, {__index = GuiTemplate})

	self:CreateChildren(script.Name, script:GetChildren())

	return self
end

return TrailsGui