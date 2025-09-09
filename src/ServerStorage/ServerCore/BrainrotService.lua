local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Brainrots
local CountdownOver = Remotes.CountdownOver :: RemoteEvent
local StartJumpPreparation = Remotes.StartJumpPreparation :: RemoteFunction
local StopRequested = Remotes.StopRequested :: RemoteEvent
local JumpEnded = Remotes.JumpEnded :: RemoteEvent

local BrainrotConfig = require(ReplicatedStorage.Configs.BrainrotConfig)
local WorldsConfig = require(ReplicatedStorage.Configs.WorldsConfig)
local BrainrotGui = ReplicatedStorage.Assets.UI.BrainrotInfoGui
local ProgressBar = require(ReplicatedStorage.Modules.UI.ProgressBar)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)
export type BrainrotService = {
    _brainrots: {[Player]: {
        BrainrotLevel: number;
        BrainrotXP: number;
    }}
} & ServiceTemplate.Type

local BrainrotService = {} :: BrainrotService

local function spawnBrainrotForPlayer(self: BrainrotService, player: Player)
    local brainrotLevel = self._brainrots[player].BrainrotLevel
    local model = BrainrotConfig.Brainrots[brainrotLevel].Model:Clone()
    local zone = self._services.ZonesService:GetPlayerZone(player)
    print(model, zone)

    for _, child in zone.BrainrotPoint:GetChildren() do
        child:Destroy()
    end

    model.Parent = zone.BrainrotPoint
    local prompt = model:FindFirstChild("ProximityPrompt")
    prompt:SetAttribute("OwnerId", player.UserId)
    local gui = BrainrotGui:Clone()
    gui.LevelLabel.Text = "Lvl " .. self._brainrots[player].BrainrotLevel
    gui.Parent = model.GuiPart
    self._progressBars[player] = ProgressBar.new(gui.ProgressBar, BrainrotConfig.Brainrots[brainrotLevel].XpToNextLevel, true)
    self._progressBars[player]:SetValue(0)

    model:PivotTo(zone.BrainrotPoint.CFrame)
    self._models[player] = model
end

local function upgradeBrainrot(self: BrainrotService, player: Player)
    local currentLevel = self._brainrots[player].BrainrotLevel

    if self._brainrots[player].BrainrotXP < BrainrotConfig.Brainrots[currentLevel].XpToNextLevel then return end

    if currentLevel + 1 > #BrainrotConfig.Brainrots then return end

    self._brainrots[player] = {
        BrainrotLevel = currentLevel + 1;
        BrainrotXP = 0;
    }

    self._services.RewardService:GiveReward(player, {FunctionName = "UpgradePoints", Data = 1})

    spawnBrainrotForPlayer(self, player)
end

local function startFeedingProcess(self: BrainrotService, player: Player)
    local amount = player.Currencies.Food.Value
    player.Currencies.Food.Value = 0

    self._brainrots[player].BrainrotXP += amount
    local currentLevel = self._brainrots[player].BrainrotLevel

    -- update food counter in HUD
    -- spawn VFX and SFX

    self._progressBars[player]:SetValue(self._brainrots[player].BrainrotXP)

    if self._brainrots[player].BrainrotXP >= BrainrotConfig.Brainrots[currentLevel].XpToNextLevel then
        upgradeBrainrot(self, player)
    end
end

local function startJumpForPlayer(self: BrainrotService, player: Player)

end

local function endJumpForPlayer(self: BrainrotService, player: Player, maxReachedHeight: number)
    local currentWorld = self._services.WorldsService:GetPlayerWorldIndex(player)
    local cashAmount = math.round(maxReachedHeight * WorldsConfig.Worlds[currentWorld].CashPerStud)
    self._services.RewardService:GiveReward(player, {FunctionName = "Cash", Data = cashAmount})

    local checkpointsPassed = 0
    local checkpointHeight = BrainrotConfig.CheckpointBaseHeight

    while maxReachedHeight > checkpointHeight do
        checkpointsPassed += 1
        checkpointHeight = BrainrotConfig.CheckpointBaseHeight * BrainrotConfig.CheckpointHeightMultiplier ^ checkpointsPassed
    end

    if checkpointsPassed > 0 then
        local wins = WorldsConfig.Worlds[currentWorld].BaseWins * WorldsConfig.Worlds[currentWorld].MultiplierWins ^ checkpointsPassed
        self._services.RewardService:GiveReward(player, {FunctionName = "Wins", Data = wins})
    end

    -- disable animation

    JumpEnded:FireClient(player)

    local prompt = self._models[player].ProximityPrompt
    prompt.Enabled = true

    local gui = self._models[player].GuiPart.BrainrotInfoGui
    gui.Enabled = true

    player:SetAttribute("CurrentCheckpoint", 0)
end

function BrainrotService:LoadSave(player: Player, data)
    local data = data or {
        BrainrotLevel = 1;
        BrainrotXP = 0;
    }

    local zone = self._services.ZonesService:GetPlayerZone(player)

    if not zone then
        while task.wait(1) do
            zone = self._services.ZonesService:GetPlayerZone(player)

            if zone then break end
        end
    end

    local feedingCircle = zone.FeedingCircle

    feedingCircle.Touched:Connect(function(otherPart: Part)
        local character: Model = otherPart.Parent
	    local touchedPlayer: Player = Players:GetPlayerFromCharacter(character)

	    if not touchedPlayer then return end

        if touchedPlayer ~= player then return end

	    if self._debounces[touchedPlayer] then return end

	    self._debounces[touchedPlayer] = true

        startFeedingProcess(self, player)

	    task.spawn(function()
		    task.wait(1)
		    self._debounces[touchedPlayer] = nil
	    end)
    end)

    self._brainrots[player] = data
    spawnBrainrotForPlayer(self, player)
end

function BrainrotService:UnloadSave(player: Player)
    local data = self._brainrots[player] or {}

    self._brainrots[player] = nil
    self._progressBars[player] = nil
    self._models[player] = nil

    return data
end

function BrainrotService:Initialize()
    self._brainrots = {}
    self._debounces = {}
    self._progressBars = {}
    self._models = {}
    self._stopRequests = {}

    self._cubicBezierUp = self._utils.CubicBezier.new(.09,.87,.76,.91)
    self._cubicBezierDown = self._utils.CubicBezier.new(.43,-0.01,.95,.76)

    StartJumpPreparation.OnServerInvoke = function(player: Player)
        if not self._models[player] then return false end

        local prompt = self._models[player].ProximityPrompt
        prompt.Enabled = false

        local gui = self._models[player].GuiPart.BrainrotInfoGui
        gui.Enabled = false

        return true
    end

    CountdownOver.OnServerEvent:Connect(function(player: Player)
        -- enable animation
        local model = self._models[player]
        local currentConfig = BrainrotConfig.Brainrots[self._brainrots[player].BrainrotLevel]
        local xpPercentage = self._brainrots[player].BrainrotXP / currentConfig.XpToNextLevel * 100
        local jumpPower = (currentConfig.MaxJumpPower - currentConfig.MinJumpPower) / 100 * xpPercentage + currentConfig.MinJumpPower
        local currentWorld = self._services.WorldsService:GetPlayerWorldIndex(player)
        local targetHeight = jumpPower * WorldsConfig.Worlds[currentWorld].JumpMultiplier
        local estimatedTime = targetHeight / BrainrotConfig.Speed
        local currentCheckpoint = 0

        local initialPivot = model:GetPivot()
        local initialY = model:GetPivot().Y

        local timeLeft = estimatedTime
        local timeElapsed = 0
        local connection, currentValue, currentHeight

        connection = RunService.Heartbeat:Connect(function(deltaTime)
            timeElapsed += deltaTime
            currentValue = self._cubicBezierUp:GetValueAtTime(timeElapsed / estimatedTime)
            currentHeight = targetHeight * currentValue

            if currentHeight > BrainrotConfig.CheckpointBaseHeight * math.pow(BrainrotConfig.CheckpointHeightMultiplier, currentCheckpoint) then
                currentCheckpoint += 1
                player:SetAttribute("CurrentCheckpoint", currentCheckpoint)
                -- change skybox
            end

            ---- SKYBOX LOGIC
            ---- Leaderboard Logic

            -- currentPosition = Vector3.new(initialX, currentHeight, initialZ)
            -- targetCFrame = CFrame.new(currentPosition)
            -- model:PivotTo(targetCFrame)
            model:PivotTo(initialPivot * CFrame.new(0, currentHeight - initialY, 0))
            timeLeft -= deltaTime

            if timeLeft <= 0 or self._stopRequests[player] then
                connection:Disconnect()
                timeLeft = estimatedTime
                timeElapsed = 0

                if self._stopRequests[player] then
                    self._stopRequests[player] = nil
                    return
                end

                connection = RunService.Heartbeat:Connect(function(deltaTime)
                    timeElapsed += deltaTime
                    currentValue = self._cubicBezierDown:GetValueAtTime(timeElapsed / estimatedTime)
                    currentHeight = targetHeight - targetHeight * currentValue

                    if currentHeight < BrainrotConfig.CheckpointBaseHeight * math.pow(BrainrotConfig.CheckpointHeightMultiplier, currentCheckpoint) then
                        currentCheckpoint -= 1
                        player:SetAttribute("CurrentCheckpoint", currentCheckpoint)
                        -- change skybox
                    end

                    if currentHeight < initialY then
                        currentHeight = initialY
                        timeLeft = 0
                    end

                    local targetPivot = initialPivot * CFrame.new(0, currentHeight - initialY, 0)
                    model:PivotTo(targetPivot)
                    timeLeft -= deltaTime

                    if timeLeft <= 0 or self._stopRequests[player] then
                        connection:Disconnect()

                        if self._stopRequests[player] then
                            self._stopRequests[player] = nil
                            return
                        end

                        endJumpForPlayer(self, player, targetHeight)
                    end
                end)
            end
        end)
    end)

    StopRequested.OnServerEvent:Connect(function(player: Player)
        self._stopRequests[player] = true
        local currentHeight = self._models[player]:GetPivot().Y
        local initialPivot = self._models[player].Parent.CFrame
        task.wait(.5)
        self._models[player]:PivotTo(initialPivot)
        -- change skybox to default
        endJumpForPlayer(self, player, currentHeight)
    end)
end

function BrainrotService.new()
    local self = setmetatable(BrainrotService, {__index = ServiceTemplate})

    return self
end

return BrainrotService