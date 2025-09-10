local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BrainrotConfig = require(ReplicatedStorage.Configs.BrainrotConfig)
local Remotes = ReplicatedStorage.Remotes.Brainrots
local StopRequested = Remotes.StopRequested :: RemoteEvent
local JumpEnded = Remotes.JumpEnded :: RemoteEvent

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local JumpFrame = {} :: ControllerTemplate.Type

local Players = game:GetService("Players")
local baseImage = "http://www.roblox.com/asset/?id=14592693718"

local function createPlayerIcon(self, player: Player)
	local tries = 0

    local sideBarFrame = self._frame.InJumpFrame.SideBarFrame
    local playerFrame = sideBarFrame.PlayerTemplate:Clone()
    playerFrame.Parent = sideBarFrame

	repeat
		local success, result = pcall(function()
			local content, isReady = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			playerFrame.Avatar.Image = isReady and content or baseImage
		end)

		if not success then
			warn("Player thumbnnail failed: " .. result)
		end

		tries +=1
	until success or tries == 3

    playerFrame.Visible = true
    self._icons[player] = playerFrame
end

local function deletePlayerIcon(self, player: Player)
	local image = self._icons[player]

	if image then
		image:Destroy()
	end

	self._icons[player] = nil
end

local function updateProgressBar(self)
	for _, player: Player in pairs(Players:GetChildren()) do
		local playerCheckpoint = player:GetAttribute("CurrentCheckpoint") or 0

		if not self._icons[player] then continue end

		if playerCheckpoint ~= self._currentCheckpoint then
			self._icons[player].Visible = false

			continue
		else
			self._icons[player].Visible = true
		end

        if not self._brainrotPoints[player] then
            self._brainrotPoints[player] = self._controllers.ZoneController:GetPlayersZone(player).BrainrotPoint
        end

        if not self._brainrotPoints[player] then continue end

        local currentHeight = self._brainrotPoints[player]:FindFirstChildOfClass("Model"):GetPivot().Y
		local percentage = math.clamp(1 - ((currentHeight - self._prevCheckpointHeight) / (self._currentCheckpointHeight - self._prevCheckpointHeight)), 0.05, 0.95)
		self._icons[player].Position = UDim2.fromScale(0.1, percentage)
	end
end

-- function JumpFrame:StartCountdown()
--     self._countdownFrame.Visible = true
--     local timeLeft = 3

--     while task.wait(1) do
--         local label = self._countdownFrame:FindFirstChild(timeLeft)

--         if not label then return end

--         label.Visible = true

--         task.spawn(function()
--             -- tween label
--             task.wait(1)
--             label.Visible = false
--         end)

--         timeLeft -= 1

--         if timeLeft < 0 then break end
--     end

--     self._countdownFrame.Visible = false
-- end

function JumpFrame:StartCountdown()
    self._countdownFrame.Visible = true
    local timeLeft = 3
    local tweenService = game:GetService("TweenService")

    while task.wait(1) do
        task.spawn(function()
            local label = self._countdownFrame:FindFirstChild(tostring(timeLeft))
        
            if not label then 
                self._countdownFrame.Visible = false
                return 
            end

            label.Visible = true
            label.TextTransparency = 0.5

            local originalSize = label.Size

            local scaleTween = tweenService:Create(label, TweenInfo.new(
                0.8,
                Enum.EasingStyle.Back,
                Enum.EasingDirection.Out
            ), {
                TextTransparency = 0,
                Size = UDim2.new(
                    originalSize.X.Scale * 1.2,
                    originalSize.X.Offset * 1.2,
                    originalSize.Y.Scale * 1.2,
                    originalSize.Y.Offset * 1.2
                )
            })
            
            scaleTween:Play()
            scaleTween.Completed:Wait()

            local fadeTween = tweenService:Create(label, TweenInfo.new(
                0.2,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.In
            ), {
                TextTransparency = 1
            })
            
            fadeTween:Play()
            fadeTween.Completed:Wait()
            
            label.Visible = false
            label.TextTransparency = 0.5
            label.Size = originalSize
        end)

        timeLeft -= 1

        if timeLeft < 0 then break end
    end

    self._countdownFrame.Visible = false
end

function JumpFrame:StartJump(currentModel)
    self._countdownFrame.Visible = false
    self._inJumpFrame.Visible = true

    local cashCounter = self._inJumpFrame.Counters.CashCounter
    local studsCounter = self._inJumpFrame.Counters.StudsCounter
    local currentWorld = self._controllers.WorldsController:GetCurrentWorldIndex() or 1
    local cashPerStud = self._configs.WorldsConfig.Worlds[currentWorld].CashPerStud
    local currentHeight, maxHeight = 0, 0

    self._runServiceConnection = RunService.RenderStepped:Connect(function()
        currentHeight = math.round(currentModel:GetPivot().Y)
        studsCounter.Text = currentHeight .. " studs"

        if currentHeight > maxHeight then
            maxHeight = currentHeight
            cashCounter.Text = currentHeight * cashPerStud
        end

        updateProgressBar(self)
    end)
end

function JumpFrame:AfterPlayerLoaded(player: Player)
    player:GetAttributeChangedSignal("CurrentCheckpoint"):Connect(function()
        self._currentCheckpoint = player:GetAttribute("CurrentCheckpoint")
        self._currentCheckpointHeight = BrainrotConfig.CheckpointBaseHeight * math.pow(BrainrotConfig.CheckpointHeightMultiplier, self._currentCheckpoint)

        if self._currentCheckpoint == 0 then
            self._prevCheckpointHeight = 0
        else
            self._prevCheckpointHeight = BrainrotConfig.CheckpointBaseHeight * math.pow(BrainrotConfig.CheckpointHeightMultiplier, self._currentCheckpoint - 1)
        end
    end)
end

function JumpFrame:Initialize()
    self._countdownFrame = self._frame.CountdownFrame
    self._inJumpFrame = self._frame.InJumpFrame
    self._runServiceConnection = nil
    self._icons = {}
    self._brainrotPoints = {}
    self._currentCheckpoint = 0
    self._currentCheckpointHeight = BrainrotConfig.CheckpointBaseHeight * math.pow(BrainrotConfig.CheckpointHeightMultiplier, self._currentCheckpoint)
    self._prevCheckpointHeight = 0

    self._controllers.BrainrotController.CountdownStarted:Subscribe(self, function()
        self:StartCountdown()
    end)

    self._controllers.BrainrotController.JumpStarted:Subscribe(self, function(currentModel)
        self:StartJump(currentModel)
    end)

    JumpEnded.OnClientEvent:Connect(function()
        self._inJumpFrame.Visible = false
        self._runServiceConnection:Disconnect()
        self._runServiceConnection = nil
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._inJumpFrame.StopJumpButton, function()
        StopRequested:FireServer()
    end)

    for _, player in pairs(Players:GetChildren()) do
		if not self._icons[player] then
			createPlayerIcon(self, player)
            self._brainrotPoints[player] = self._controllers.ZoneController:GetPlayersZone(player).BrainrotPoint
		end
	end

	Players.PlayerAdded:Connect(function(player: Player)
		if not self._icons[player] then
            createPlayerIcon(self, player)
            self._brainrotPoints[player] = self._controllers.ZoneController:GetPlayersZone(player).BrainrotPoint
		end
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		deletePlayerIcon(self, player)
        self._brainrotPoints[player] = nil
	end)
end

function JumpFrame.new(frame: Frame)
    local self = setmetatable(JumpFrame, {__index = ControllerTemplate})
    self._frame = frame

    return self
end

return JumpFrame