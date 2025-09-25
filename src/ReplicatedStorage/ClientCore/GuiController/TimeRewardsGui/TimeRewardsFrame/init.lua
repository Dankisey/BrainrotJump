local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local FormatTime = require(ReplicatedStorage.Modules.Utils.FormatTime)
local Config = require(ReplicatedStorage.Configs.TimeRewardsConfig)
local RewardFrame = require(script.RewardFrame)

local DevProductRequested = ReplicatedStorage.Remotes.Monetization.DevProductRequested
local Remotes = ReplicatedStorage.Remotes.TimeRewards
local CycleStarted = Remotes.CycleStarted
local Skipped = Remotes.Skipped

local TimeRewardsFrame = {}

local function getNearestTimer(self)
    local minTime = math.huge
    local timer = nil

    for _, rewardFrame in pairs(self._rewardFrames) do
        if (not rewardFrame.Timer.IsFinished) and rewardFrame.Timer:GetLeftTime() < minTime then
            minTime = rewardFrame.Timer:GetLeftTime()
            timer = rewardFrame.Timer
        end
    end

    return timer
end

local function disconnectFromTimer(self)
    if self._currentTimer then
        self._currentTimer.Updated:Unsubscribe(self)
    end
end

local function updateButton(self)
    if self._readyRewards > 0 then
        disconnectFromTimer(self)

        if self._buttonTextLabel then
            self._buttonTextLabel.Text = "Claim!"
        end

        self._infoPin:TurnOn()
    else
        local timer = getNearestTimer(self)
        disconnectFromTimer(self)

        if timer then
            timer.Updated:Subscribe(self, function(leftTime: number)
                self._buttonTextLabel.Text = FormatTime(leftTime, 2)
            end)

            self._currentTimer = timer
        end

        self._infoPin:TurnOff()
    end
end

function TimeRewardsFrame:DecreaceReadyRewardsAmount()
    self._readyRewards -= 1
    updateButton(self)
end

function TimeRewardsFrame:IncreaceReadyRewardsAmount()
    self._readyRewards += 1
    updateButton(self)
end

function TimeRewardsFrame:AfterPlayerLoaded(player: Player)
    local joinTime = player:GetAttribute("JoinTime")

    if not joinTime then
        player:GetAttributeChangedSignal("JoinTime"):Wait()
        joinTime = player:GetAttribute("JoinTime")
    end

    local rewardsHolder = self._frame:WaitForChild("RewardsHolder")
    self._rewardFrames = {}

    for i = 1, #Config.Rewards do
        local rewardFrame = rewardsHolder:WaitForChild(i)
        self._rewardFrames[i] = RewardFrame.new(rewardFrame, self._controllers)
        self._rewardFrames[i]:Reset(joinTime)
    end

    self._buttonTextLabel = self._controllers.GuiController.MainGui.LeftSide.TimeRewardsButton.Label
    self._infoPin = self._controllers.GuiController.MainGui.LeftSide.TimeRewardsPin
    self._infoPin:TurnOff()
    updateButton(self)

    CycleStarted.OnClientEvent:Connect(function(countTime: number)
        for _, rewardFrame in pairs(self._rewardFrames) do
            rewardFrame:Reset(countTime)
        end

        self._readyRewards = 0
        updateButton(self)
    end)

    Skipped.OnClientEvent:Connect(function()
        for _, rewardFrame in pairs(self._rewardFrames) do
            rewardFrame:Skip()
        end
    end)
end

function TimeRewardsFrame:Initialize()
	self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame:WaitForChild("CloseButton"), function()
        self._controllers.GuiController.TimeRewardsGui:Disable()
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame:WaitForChild("SkipButton"), function()
        DevProductRequested:FireServer(Config.SkipProductId)
    end)
end

function TimeRewardsFrame.new(frame: Frame)
    local self = setmetatable(TimeRewardsFrame, {__index = ControllerTemplate})
    self._readyRewards = 0
    self._frame = frame

	return self
end

return TimeRewardsFrame