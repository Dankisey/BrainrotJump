local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiTemplate = require(ReplicatedStorage.Modules.UI.AnimatedGuiTemplate)

local TimeRewardsGui = {}

function TimeRewardsGui.new()
	local self = setmetatable(TimeRewardsGui, {__index = GuiTemplate})

	self:CreateChildren(script.Name, script:GetChildren())

	return self
end

return TimeRewardsGui