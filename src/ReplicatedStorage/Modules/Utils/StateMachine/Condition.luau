--!strict

local Classes = require(script.Parent.SM_Classes)

local Condition = {}
Condition.__index = Condition

function Condition.new(name: string) : Classes.Condition
	local self = setmetatable({} :: Classes.Condition, Condition)
	self.Name = name
	self.ExitCondition = nil
	self.ExitAction = nil
	self.TransitionState = nil
	return self
end

function Condition:Evaluate(deltaTime: number): boolean
	if not self.ExitCondition then
		return false
	end

	if self.ExitCondition(deltaTime) then
		if self.ExitAction then
			self.ExitAction()
		end

		return true
	else
		return false
	end
end

return Condition
