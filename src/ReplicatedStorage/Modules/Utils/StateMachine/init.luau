--!strict

local Classes = require(script.SM_Classes)

local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new() : Classes.StateMachine
	local self = setmetatable({} :: Classes.StateMachine , StateMachine)
	self.CurrentState = nil
	self.IsRunning = false
	return self
end

function StateMachine:SwitchState(newState : Classes.State)
	
	local oldState = self.CurrentState
	
	self.CurrentState = nil

	if oldState then
		oldState:Exit()
	end

	if newState then
		newState:Enter()
	end
	
	self.CurrentState = newState
end

function StateMachine:Update(deltaTime : number)
	if self.CurrentState and self.IsRunning then
		
		local condition = self.CurrentState:CheckForCondition(deltaTime)
		
		if condition then
			self:SwitchState(condition.TransitionState)
			return
		end
		
		self.CurrentState:Update(deltaTime)
	end
end

function StateMachine:Start(newState : Classes.State)
	self:SwitchState(newState)
	self.IsRunning = true
end

function StateMachine:Pause()
	self.IsRunning = false
end

function StateMachine:Resume()
	self.IsRunning = true
end

function StateMachine:Stop(endCurrentState : boolean?)
	self.IsRunning = false
	if endCurrentState and self.CurrentState then
		self.CurrentState:Exit()
	end
end

function StateMachine:CurrentStateName()
	if not self.CurrentState then
		return ""
	end
	return 	self.CurrentState.Name
end

return StateMachine
