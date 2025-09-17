local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiTemplate = require(ReplicatedStorage.Modules.UI.AnimatedGuiTemplate)

local GroupRewardsGui = {}

function GroupRewardsGui.new()
	local self = setmetatable(GroupRewardsGui, {__index = GuiTemplate})

	self:CreateChildren(script.Name, script:GetChildren())

	return self
end

return GroupRewardsGui