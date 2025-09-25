local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.DailyRewards
local DailyRewardClaimed = Remotes.DailyRewardClaimed
local DailyRewardUpdated = Remotes.DailyRewardUpdated

local Config = require(ReplicatedStorage.Configs.DailyRewardsConfig)

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)
local Players = game:GetService("Players")

local DailyRewardsService = {}

local function updateShowingTask(self, player)
	if self._showingTasks[player] then
		task.cancel(self._showingTasks[player])
	end

	local lastClaimedRewardTime = player:WaitForChild("DailyRewards"):WaitForChild("LastClaimedRewardTime")
	local timeSinceLastReward = os.time() - lastClaimedRewardTime.Value

	if timeSinceLastReward < Config.SecondsInOneDay then
		task.spawn(function()
			task.wait(Config.SecondsInOneDay - timeSinceLastReward)

			DailyRewardUpdated:FireClient(player)
			self._showingTasks[player] = nil
		end)
	end
end

local function onDailyRewardClaimed(self, player)
	if self._debounces[player] then return end

    local dailyRewardsInfo = player.DailyRewards
	local lastClaimedRewardIndex = dailyRewardsInfo.LastClaimedRewardIndex
	local lastClaimedRewardTime = dailyRewardsInfo.LastClaimedRewardTime

	self._debounces[player] = true

	if lastClaimedRewardTime.Value == 0 or os.time() - lastClaimedRewardTime.Value >= Config.SecondsInOneDay then
		lastClaimedRewardTime.Value = os.time()
		lastClaimedRewardIndex.Value = math.clamp(lastClaimedRewardIndex.Value + 1, 1, #Config.Rewards)

		local rewardInfo = Config.Rewards[lastClaimedRewardIndex.Value]
		self._services.RewardService:GiveMultipleRewards(player, rewardInfo.Rewards)

		if lastClaimedRewardIndex.Value >= #Config.Rewards then
			lastClaimedRewardIndex.Value = 0
		end
	end

	updateShowingTask(self, player)

	task.spawn(function()
		task.wait(2)
		self._debounces[player] = nil
	end)
end

function DailyRewardsService:Initialize()
	DailyRewardClaimed.OnServerEvent:Connect(function(player)
		onDailyRewardClaimed(self, player)
	end)

    Players.PlayerAdded:Connect(function(player: Player)
        task.spawn(updateShowingTask, self, player)
    end)

	for _, player: Player in pairs(Players:GetChildren()) do
		task.spawn(updateShowingTask, self, player)
	end

	Players.PlayerRemoving:Connect(function(player: Player)
		if self._showingTasks[player] then
			task.cancel(self._showingTasks[player])
			self._showingTasks[player] = nil
		end
	end)
end

function DailyRewardsService.new()
	local self = setmetatable(DailyRewardsService, {__index = ServiceTemplate})
	self._showingTasks = {}
	self._debounces = {}

	return self
end

return DailyRewardsService