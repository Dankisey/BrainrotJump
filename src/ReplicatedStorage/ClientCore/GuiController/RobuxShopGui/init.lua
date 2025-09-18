local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiTemplate = require(ReplicatedStorage.Modules.UI.AnimatedGuiTemplate)

local RobuxShopGui = {}

function RobuxShopGui.new()
	local self = setmetatable(RobuxShopGui, {__index = GuiTemplate})

	self:CreateChildren(script.Name, script:GetChildren())

	return self
end

return RobuxShopGui