--!strict

local Classes = require(script.Parent.SM_Classes)

local State = {}
State.__index = State

function State.new(name : string) : Classes.State
	local self = setmetatable({} :: Classes.State ,State)
	self.Name = name
	self.Conditions = {}
	self.isRunning = false

	self.EnterAction = nil
	self.UpdateAction = nil
	self.ExitAction = nil

	return self
end

function State:Enter()
	self.isRunning = false
	self.EnterAction()
end

function State:Update(deltaTime : number)
	self.UpdateAction(deltaTime)
end

function State:Exit()
	self.ExitAction()
	self.isRunning = false
end

function State:AddCondition(condition : Classes.Condition)
	table.insert(self.Conditions, condition)
end

function State:CheckForCondition(deltaTime : number) : Classes.Condition?
	for _, condition in pairs(self.Conditions) do
		if condition:Evaluate(deltaTime) then
			return condition
		end
	end
	
	return nil
end

return State
