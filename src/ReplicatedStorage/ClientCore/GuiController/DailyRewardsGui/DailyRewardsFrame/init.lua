local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("DailyRewards")
local DailyRewardClaimed = Remotes:WaitForChild("DailyRewardClaimed")
local DailyRewardUpdated = Remotes:WaitForChild("DailyRewardUpdated")

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local Config = require(ReplicatedStorage.Configs.DailyRewardsConfig)
local RewardFrame = require(script.RewardFrame)

local DailyRewards = {}

local function updateRewardFrames(self)
    for i = 1, self._lastClaimedRewardIndex.Value do
        self._rewardFrames[i]:SetClaimedStatus(true)
        self._rewardFrames[i]:SetClaimMask(false)
    end

    for i = self._lastClaimedRewardIndex.Value + 1, #Config.Rewards do
        self._rewardFrames[i]:SetClaimedStatus(false)
        self._rewardFrames[i]:SetClaimMask(false)
    end
end

local function disconnectRewardButton(self)
    if self._currentRewardFrame then
        self._controllers.ButtonsInteractionsConnector:DisconnectButton(self._currentRewardFrame.Button)
    end
end

local function connectRewardButton(self)
    disconnectRewardButton(self)
    local rewardFrame = self._rewardFrames[self._lastClaimedRewardIndex.Value + 1]
    self._currentRewardFrame = rewardFrame
    self._timerLabel.Visible = false
    rewardFrame:SetClaimMask(true)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(rewardFrame.Button, function()
		local timePassed = os.time() - self._lastClaimedRewardTime.Value

		if timePassed < Config.SecondsInOneDay then return end

		DailyRewardClaimed:FireServer()
		self._controllers.GuiController.DailyRewardsGui:Disable()
        self._timerLabel.Visible = true
        disconnectRewardButton(self)
        updateRewardFrames(self)
	end)
end

local function startTimer(self)
    if self._isTimerEnabled then return end

    task.spawn(function()
        self._isTimerEnabled = true
        local endTime = self._lastClaimedRewardTime.Value + Config.SecondsInOneDay
	    local remainingTime = endTime - os.time()
	    self._timerLabel.Visible = true

	    while os.time() < endTime do
		    remainingTime = endTime - os.time()
		    self._timerLabel.Text = self._utils.FormatTime(remainingTime, 3)
		    task.wait(1)
	    end

	    if os.time() >= endTime then
		    self._timerLabel.Visible = false
            updateRewardFrames(self)
            connectRewardButton(self)
	    end

        self._isTimerEnabled = false
    end)
end

function DailyRewards:AfterPlayerLoaded(player: Player)
    local DailyRewardsFolder = player:WaitForChild("DailyRewards")
    self._lastClaimedRewardTime = DailyRewardsFolder:WaitForChild("LastClaimedRewardTime")
    self._lastClaimedRewardIndex = DailyRewardsFolder:WaitForChild("LastClaimedRewardIndex")

    updateRewardFrames(self)

    self._lastClaimedRewardIndex.Changed:Connect(function()
        updateRewardFrames(self)
    end)

    self._lastClaimedRewardTime.Changed:Connect(function()
        startTimer(self)
    end)

    if os.time() - self._lastClaimedRewardTime.Value >= Config.SecondsInOneDay then
        connectRewardButton(self)
        self._timerLabel.Visible = false
        self._controllers.GuiController.DailyRewardsGui:Enable()
	else
        self._timerLabel.Visible = true
		startTimer(self)
	end

    DailyRewardUpdated.OnClientEvent:Connect(function()
		connectRewardButton(self)
        self._timerLabel.Visible = false
        self._controllers.GuiController.DailyRewardsGui:Enable()
	end)
end

function DailyRewards:Initialize()
    self._timerLabel = self._frame:WaitForChild("TimerLabel")

    local rewardsHolder = self._frame:WaitForChild("RewardsHolder")
    self._rewardFrames = {}

    for i = 1, #Config.Rewards - 1 do
        table.insert(self._rewardFrames, RewardFrame.new(rewardsHolder:WaitForChild(i), Config.Rewards[i]))
    end

    table.insert(self._rewardFrames, RewardFrame.new(self._frame:WaitForChild("SpecialDailyReward"), Config.Rewards[#Config.Rewards]))

    for i = 1, #Config.Rewards do
        self._controllers.TooltipsController:RegisterTooltip(self._rewardFrames[i].Button, Config.Rewards[i].TooltipInfo)
    end

	self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame:WaitForChild("CloseButton"), function()
        self._controllers.GuiController.DailyRewardsGui:Disable()
    end)
end

function DailyRewards.new(frame: Frame)
    local self = setmetatable(DailyRewards, {__index = ControllerTemplate})
    self._frame = frame

	return self
end

return DailyRewards