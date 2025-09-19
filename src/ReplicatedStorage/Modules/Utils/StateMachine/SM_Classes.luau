
export type State = {
	Name: string,
	Conditions: { [number]: Condition },
	isRunning: boolean,
	EnterAction: (() -> ())?,
	UpdateAction: ((deltaTime: number) -> ())?,
	ExitAction: (() -> ())?,
	Enter: (self: StateClass) -> (),
	Update: (self: StateClass, deltaTime: number) -> (),
	Exit: (self: StateClass) -> (),
	AddCondition: (self: StateClass, condition: Condition) -> (),
	CheckForCondition: (self: StateClass, deltaTime: number) -> Condition?
}

export type Condition = {
	Name: string,
	ExitCondition: ((deltaTime: number) -> boolean)?,
	ExitAction: (() -> ())?,
	TransitionState: State?,
	Evaluate: (self: ConditionClass, deltaTime: number) -> boolean
}

export type StateMachine = {
	CurrentState: State?,
	IsRunning: boolean,
	SwitchState: (self: StateMachine, newState: State) -> (),
	Update: (self: StateMachine, deltaTime: number) -> (),
	Start: (self: StateMachine, newState: State) -> (),
	Pause: (self: StateMachine) -> (),
	Resume: (self: StateMachine) -> (),
	Stop: (self: StateMachine, endCurrentState: boolean?) -> (),
	CurrentStateName: (self: StateMachine) -> string,
}

local Classes = {}

return Classes
