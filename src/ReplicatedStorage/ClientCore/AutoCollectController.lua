local AutoCollectController = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local StateMachine = require(ReplicatedStorage.Modules.Utils.StateMachine)
local State = require(ReplicatedStorage.Modules.Utils.StateMachine.State)
local Condition = require(ReplicatedStorage.Modules.Utils.StateMachine.Condition)
local Classes = require(ReplicatedStorage.Modules.Utils.StateMachine.SM_Classes)

local player = Players.LocalPlayer

local movementKeys = {
	[Enum.KeyCode.W] = true,
	[Enum.KeyCode.A] = true,
	[Enum.KeyCode.S] = true,
	[Enum.KeyCode.D] = true
}

local active = false
local activeTime = 3
local inActiveTime = 35

function AutoCollectController:Update(deltaTime)
	self._stateMachine:Update(deltaTime)
	self:CheckIfIdle(deltaTime)
end

function AutoCollectController:Enable()
	active = true
	self._stateMachine:Start(self._states["Idle"])
end

function AutoCollectController:Disable()
	active = false
	self._stateMachine:Stop()
	self:CancelMoveTo()
end

function AutoCollectController:Idle()
	self._states["Idle"].EnterAction = function()	
		player:SetAttribute("AutoFarmState", "Idle")
	end

	self._states["Idle"].UpdateAction = function(deltaTime)

	end

	self._states["Idle"].ExitAction = function()

	end

	self._states["Idle"]:AddCondition(self._conditions["IdleToCollectFood"])
	self._states["Idle"]:AddCondition(self._conditions["IdleToHuntEgg"])
end

function AutoCollectController:CollectFood()
	self._states["CollectFood"].EnterAction = function()
		player:SetAttribute("AutoFarmState", "CollectFood")

		self:MoveTo(self._selectedFoodPile.Position -  (self._selectedFoodPile.Size / 2), function()
			print("Cant Reach location", self._selectedFoodPile)
		end)

	end

	self._states["CollectFood"].UpdateAction = function(deltaTime)

    end

	self._states["CollectFood"].ExitAction = function()

    end

	self._states["CollectFood"]:AddCondition(self._conditions["CollectFoodToDepositFood"])
	self._states["CollectFood"]:AddCondition(self._conditions["CollectFoodToIdle"])
end

function AutoCollectController:DepositFood()
	self._states["DepositFood"].EnterAction = function()
		player:SetAttribute("AutoFarmState", "DepositFood")

		local selectedFeeder = self:GetClosestFeederToPlayer()

		self:MoveTo(selectedFeeder.Position, function()
			print("Cant Reach location")
		end)
	end

	self._states["DepositFood"].UpdateAction = function(deltaTime)

	end

	self._states["DepositFood"].ExitAction = function()

	end

	self._states["DepositFood"]:AddCondition(self._conditions["DepositFoodToIdle"])
end

function AutoCollectController:SetUpConditions()
	self._conditions["IdleToCollectFood"].TransitionState = self._states["CollectFood"]
	self._conditions["IdleToCollectFood"].ExitCondition = function()
		local closestFoodPile = self:GetClosestFoodPileToPlayer()
		if closestFoodPile then
			self._selectedFoodPile = closestFoodPile
			return true
		end

		return false
	end

	self._conditions["CollectFoodToIdle"].TransitionState = self._states["Idle"]
	self._conditions["CollectFoodToIdle"].ExitCondition = function()
		if self._selectedFoodPile:GetAttribute("FoodLeft") <= 0 then
			return true
		end

		return false
	end

	self._conditions["CollectFoodToDepositFood"].TransitionState = self._states["DepositFood"]
	self._conditions["CollectFoodToDepositFood"].ExitCondition = function()
		if self._food.Value >= self._player:GetAttribute("FoodCapacity") then
			return true
		end

		return false
	end

	self._conditions["DepositFoodToIdle"].TransitionState = self._states["Idle"]
	self._conditions["DepositFoodToIdle"].ExitCondition = function()
		if self._food.Value == 0 then
			return true
		end

		return false
	end
end

function AutoCollectController:GetClosestFoodPileToPlayer()
	local closestDistance = math.huge -- Initialize with a very large number
	local closestFoodPile = nil

	for _, foodPile in pairs(self._controllers.ZoneController:GetFoodPilesFolder():GetChildren()) do
		if not foodPile:GetAttribute("FoodLeft") then continue end

		if tonumber(foodPile:GetAttribute("FoodLeft")) < 0 then continue end

		local distance = player:DistanceFromCharacter(foodPile.Position)

		if distance < closestDistance then
			closestDistance = distance
			closestFoodPile = foodPile
		end
	end

	return closestFoodPile
end

function AutoCollectController:GetClosestFeederToPlayer()
	local closestDistance = math.huge -- Initialize with a very large number
	local closestFeeder = nil

	for _, feeder in pairs(self._feeders) do
		if not feeder or not feeder:IsA("Part") then
			continue
		end

		local distance = self._player:DistanceFromCharacter(feeder.Position)

		if distance < closestDistance then
			closestDistance = distance
			closestFeeder = feeder
		end
	end

	return closestFeeder
end

function AutoCollectController:MoveTo(position : Vector3, OnFailed : ()->())
	self:CancelMoveTo()

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if humanoid then
		-- Create a path object
		local path = PathfindingService:CreatePath({
			AgentRadius = 2, -- Adjust as needed for your character size
			AgentHeight = 5,
			AgentCanJump = true,
			AgentCanClimb = true,
			AgentMaxSlope = 45,
		})

		-- Compute the path to the target position
		path:ComputeAsync(character.PrimaryPart.Position, position)

		-- Check if the path is valid
		if path.Status == Enum.PathStatus.Success then
			-- Get waypoints from the path
			local waypoints = path:GetWaypoints()

			self._isMoving = true -- Set the flag to indicate the player is moving

			-- Move along each waypoint
			for _, waypoint in ipairs(waypoints) do
				if not self._isMoving then break end -- Stop moving if canceled
				humanoid:MoveTo(waypoint.Position)
				humanoid.MoveToFinished:Wait()

				-- Jump if the waypoint action requires a jump
				if waypoint.Action == Enum.PathWaypointAction.Jump then
					humanoid.Jump = true
				end
			end
		else
			print(path.Status, character.PrimaryPart.Position, position)
			if OnFailed then
				OnFailed()
			end

			warn("Pathfinding failed.")
		end
	end
end

function AutoCollectController:CancelMoveTo()
	if not self._isMoving then
		return
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChild("Humanoid")

	if humanoid then
		self._isMoving = false -- Set the flag to stop movement
		humanoid:MoveTo(humanoid.RootPart.Position) -- Cancel the movement by stopping the humanoid
	end
end

function AutoCollectController:CheckIfIdle(deltaTime : number)
	if not self._player.Character or not self._player.Character.PrimaryPart then
		return
	end

	local currentPosition = self._player.Character.PrimaryPart.Position

	if (currentPosition - self._lastPlayerPos).magnitude < 0.1 and 
		not player:GetAttribute("IsDepositing") then

		self._idleTimer += deltaTime -- Increment idle time using deltatime

		if player:GetAttribute("AutoFarm") then
			if self._idleTimer >= activeTime then
				self._stateMachine:SwitchState(self._states["Idle"])
				self._stateMachine:Resume()
				self._idleTimer = 0
			end
		else
			if self._idleTimer >= inActiveTime then
				player:SetAttribute("AutoFarm", true)
				self._idleTimer = 0
			end
		end
	else
		self._idleTimer = 0 -- Reset idle time if the player moves
	end

	self._lastPlayerPos = currentPosition
end

function AutoCollectController:OnInputBegan(input, gameProcessedEvent)
	if not player:GetAttribute("AutoCollect") then
		return
	end

	if movementKeys[input.KeyCode] and self._stateMachine.IsRunning then
		self._stateMachine:Pause()
		self._stateMachine:SwitchState(self._states["Idle"])
		self:CancelMoveTo()
	end
end

function AutoCollectController:AfterPlayerLoaded()
	self._food = self._player:WaitForChild("Currencies"):WaitForChild("Food")
	self._feeders = self._controllers.ZoneController:GetFeedingPart():GetChildren()
end

function AutoCollectController:Initialize(player: Player)
    self._player = player
    self._idleTimer = 0
    self._isMoving = false
	self._selectedFoodPile = nil :: Model

	self._states["Idle"] = State.new("Idle") :: Classes.State
	self._states["CollectFood"] = State.new("CollectFood") :: Classes.State
	self._states["DepositFood"] = State.new("DepositFood") :: Classes.State

	self._conditions["IdleToCollectFood"] = Condition.new("IdleToCollectFood") :: Classes.Condition
	self._conditions["CollectFoodToDepositFood"] = Condition.new("CollectFoodToDepositFood") :: Classes.Condition
	self._conditions["CollectFoodToIdle"] = Condition.new("CollectFoodToIdle") :: Classes.Condition
	self._conditions["DepositFoodToIdle"] = Condition.new("DepositFoodToIdle") :: Classes.Condition

    player.AttributeChanged:Connect(function(attribute: string) 
		if attribute == "AutoFarm" then
			if player:GetAttribute("AutoFarm") then
				self:Enable()
			else
				self:Disable()
			end
		end

		if attribute == "IsDepositing" then
			self._idleTimer = 0
		end

		if attribute == "AutoCollect" then
			self.UpdateConnection = RunService.Heartbeat:Connect(function(deltaTime)
				self:Update(deltaTime)
			end)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        self:OnInputBegan(input, gameProcessedEvent)
    end)

	self:Idle()
	self:CollectFood()
	self:DepositFood()

	self:SetUpConditions()

	if player:GetAttribute("AutoCollect") then
		self.UpdateConnection = RunService.Heartbeat:Connect(function(deltaTime)
			self:Update(deltaTime)
		end)
	end

	self._lastPlayerPos = player.Character.PrimaryPart.Position
end

function AutoCollectController.new()
    local self = setmetatable(AutoCollectController, {__index = ControllerTemplate})

    self._stateMachine = StateMachine.new() :: Classes.StateMachine
    self._states = {} :: {[string]: Classes.State}
    self._conditions = {} :: {[string]: Classes.Condition}

    return self
end

return AutoCollectController