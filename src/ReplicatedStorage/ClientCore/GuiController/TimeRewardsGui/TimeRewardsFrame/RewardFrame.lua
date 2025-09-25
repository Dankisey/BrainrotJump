local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FormatTime = require(ReplicatedStorage.Modules.Utils.FormatTime)
local Config = require(ReplicatedStorage.Configs.TimeRewardsConfig)
local Timer = require(ReplicatedStorage.Modules.Utils.Timer)

local Remotes = ReplicatedStorage.Remotes.TimeRewards
local ClaimingAttempted = Remotes.ClaimingAttempted
local ClaimingApproved = Remotes.ClaimingApproved

local RewardFrame = {}

local function onRewardClaimed(self)
    self._controllers.GuiController.TimeRewardsGui.TimeRewardsFrame:DecreaceReadyRewardsAmount()
    self._controllers.ButtonsInteractionsConnector:DisconnectButton(self._button)
    self._claimedMask.Visible = true
    self._timerMask.Visible = false
    self._claimMask.Visible = false
    self._isClaimed = true
end

local function onTimerFinished(self)
    self._controllers.GuiController.TimeRewardsGui.TimeRewardsFrame:IncreaceReadyRewardsAmount()
    self._claimedMask.Visible = false
    self._timerMask.Visible = false
    self._claimMask.Visible = true

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._button, function()
        ClaimingAttempted:FireServer(self._rewardIndex)
    end)
end

local function initialize(self)
    local config = Config.Rewards[self._rewardIndex]
	self._button:WaitForChild("AmountLabel").Text = config.ShowingInfo
	self._button:WaitForChild("RewardImage").Image = config.Icon

    self._claimedMask = self._button:WaitForChild("ClaimedMask")
    self._claimMask = self._button:WaitForChild("ClaimMask")
    self._timerMask = self._button:WaitForChild("TimerMask")

    self.Timer.Updated:Subscribe(self, function(leftTime: number)
        self._timerMask.TimerLabel.Text = FormatTime(leftTime, 2)
    end)

    self.Timer.Finished:Subscribe(self, function()
        onTimerFinished(self)
    end)

    ClaimingApproved.OnClientEvent:Connect(function(rewardIndex: number)
        if rewardIndex == self._rewardIndex then
            if config.Rewards.Egg then 
                self._controllers.GuiController.TimeRewardsGui:Disable() 
            end

            onRewardClaimed(self)
        end
    end)

    self._controllers.TooltipsController:RegisterTooltip(self._button, config.TooltipInfo)
    self._frame.Visible = true
end

function RewardFrame:Skip()
    if not self.Timer.IsFinished then
        self.Timer:ForceFinish()
    end
end

function RewardFrame:Reset(countTime: number)
    self._claimedMask.Visible = false
    self._claimMask.Visible = false
    self._timerMask.Visible = true
    self._isClaimed = false

    self.Timer:Start(countTime + Config.Rewards[self._rewardIndex].Time - os.time())
end

function RewardFrame.new(frame: Frame, controllers)
	local self = setmetatable({}, {__index = RewardFrame})
    self.Timer = Timer.new()

    self._button = frame:WaitForChild("Button")
    self._rewardIndex = tonumber(frame.Name)
    self._controllers = controllers
	self._frame = frame

    initialize(self)

	return self
end

return RewardFrame