local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Configs.TimeRewardsConfig)

local Remotes = ReplicatedStorage.Remotes.TimeRewards
local ClaimingAttempted = Remotes.ClaimingAttempted
local ClaimingApproved = Remotes.ClaimingApproved
local CycleStarted = Remotes.CycleStarted
local Skipped = Remotes.Skipped

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)
local Players = game:GetService("Players")

local TimeRewardsService = {}

local function startNewCycle(self, player: Player)
    table.clear(self._playerSaves[player].ClaimedRewards)
    self._playerSaves[player].StartTime = os.time()
    self._playerSaves[player].IsSkipped = false

    task.delay(1, function()
        if not player then return end

        CycleStarted:FireClient(player, self._playerSaves[player].StartTime)
    end)
end

local function processReward(self, player: Player, index: number)
    ClaimingApproved:FireClient(player, index)
    table.insert(self._playerSaves[player].ClaimedRewards, index)
    self._services.RewardService:GiveMultipleRewards(player, Config.Rewards[index].Rewards)

    if #self._playerSaves[player].ClaimedRewards == #Config.Rewards then
        startNewCycle(self, player)
    end
end

local function onRewardClaimingAttempted(self, player: Player, index: number)
    if self._debounces[player] then return end

    self._debounces[player] = true

    task.delay(.5, function()
        self._debounces[player] = nil
    end)

    if not self._playerSaves[player] then return end

	if table.find(self._playerSaves[player].ClaimedRewards, index) then return end

    local rewardConfig = Config.Rewards[index]

    if not rewardConfig then
        return warn("Reward with index", index, "is not in config [TimeRewards]")
    end

    local targetTime = self._playerSaves[player].StartTime + rewardConfig.Time

    if os.time() >= targetTime or self._playerSaves[player].IsSkipped then
        processReward(self, player, index)
    else
        self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "Reward is not yet ready")
    end
end

local function onPlayerAdded(self, player: Player)
    local joinTime = player:GetAttribute("JoinTime")

    if not joinTime then
        player:GetAttributeChangedSignal("JoinTime"):Wait()
        joinTime = player:GetAttribute("JoinTime")
    end

    self._playerSaves[player] = {
        StartTime = joinTime;
        ClaimedRewards = {};
        IsSkipped = false;
    }
end

function TimeRewardsService:TrySkip(player: Player)
    if not self._playerSaves[player] then return false end

    self._playerSaves[player].IsSkipped = true
    Skipped:FireClient(player)

    return true
end

function TimeRewardsService:Initialize()
    ClaimingAttempted.OnServerEvent:Connect(function(player: Player, rewardIndex: number)
        onRewardClaimingAttempted(self, player, rewardIndex)
    end)

    Players.PlayerAdded:Connect(function(player)
        onPlayerAdded(self, player)
    end)

    for _, player: Player in pairs(Players:GetPlayers()) do
        onPlayerAdded(self, player)
    end

	Players.PlayerRemoving:Connect(function(player: Player)
        self._playerSaves[player] = nil
	end)
end

function TimeRewardsService.new()
	local self = setmetatable(TimeRewardsService, {__index = ServiceTemplate})
	self._playerSaves = {}
    self._debounces = {}

	return self
end

return TimeRewardsService