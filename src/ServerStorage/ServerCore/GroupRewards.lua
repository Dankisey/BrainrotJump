local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local GroupRewardRequested = Remotes.GroupRewardRequested
local Config = require(ReplicatedStorage.Configs.GroupRewardsConfig)

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local GroupRewards = {}

local function tryGiveReward(self, player: Player)
	if self._debounces[player] then return end

	self._debounces[player] = true

	task.delay(.5, function()
		self._debounces[player] = nil
	end)

	if player:GetAttribute("IsGroupRewardClaimed") then
		self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "Reward is already claimed")

		return
	end

	if not player:IsInGroup(self._configs.GroupId.Value) then
		self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "One or more requirements have not been met.")

		return
	end

	player:SetAttribute("IsGroupRewardClaimed", true)
	self._services.ServerMessagesSender:SendMessageToPlayer(player, "Congrats", "Reward Claimed!")
	self._services.RewardService:GiveMultipleRewards(player, Config.Rewards)
end

function GroupRewards:Initialize()
	GroupRewardRequested.OnServerEvent:Connect(function(player: Player)
		tryGiveReward(self, player)
	end)
end

function GroupRewards.new()
    local self = setmetatable(GroupRewards, {__index = ServiceTemplate})
    self._debounces = {}

	return self
end

return GroupRewards