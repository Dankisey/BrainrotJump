local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiTemplate = require(ReplicatedStorage.Modules.UI.GuiTemplate)

local RebirthGui = {}

function RebirthGui.new()
	local self = setmetatable(RebirthGui, {__index = GuiTemplate})

	self:CreateChildren(script.Name, script:GetChildren())

	return self
end

return RebirthGui