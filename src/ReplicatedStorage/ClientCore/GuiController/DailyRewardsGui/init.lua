local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiTemplate = require(ReplicatedStorage.Modules.UI.AnimatedGuiTemplate)

local DailyRewardsGui = {}

function DailyRewardsGui.new()
	local self = setmetatable(DailyRewardsGui, {__index = GuiTemplate})

	self:CreateChildren(script.Name, script:GetChildren())

	return self
end

return DailyRewardsGui