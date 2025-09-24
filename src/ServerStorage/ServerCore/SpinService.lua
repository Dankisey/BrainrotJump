local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Configs.SpinConfig)
local Remotes = ReplicatedStorage.Remotes.Spin
local FreeSpinTimerUpdated = Remotes.FreeSpinTimerUpdated
local Attempted = Remotes.Attempted
local Approved = Remotes.Approved
local Finished = Remotes.Finished
local Declined = Remotes.Declined

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local Players = game:GetService("Players")

local SpinService = {}

function SpinService:Initialize()
    Attempted.OnServerEvent:Connect(function(player: Player)
        if self._debounces[player] then return end

        local availableSpins = player:GetAttribute("SpinsAmount") or 0
        self._debounces[player] = true

        if self._pendingRewards[player] then
            self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "Your previous reward is still processing")
            Declined:FireClient(player)
        elseif availableSpins <= 0 then
            self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "You have no spins left")
            Declined:FireClient(player)
        else
            player:SetAttribute("SpinsAmount", availableSpins - 1)
            local rewardIndex = self._utils.GetChancedRewardIndex(Config.Rewards)
            self._pendingRewards[player] = rewardIndex
            Approved:FireClient(player, rewardIndex)
        end

        task.delay(Config.FullSpinTime * Config.FullSpinsAmount.Min, function()
            if self._debounces[player] then
                self._debounces[player] = nil
            end
        end)
    end)

    Finished.OnServerEvent:Connect(function(player: Player)
        local rewardIndex = self._pendingRewards[player]
        self._pendingRewards[player] = nil

        if not rewardIndex then return end

        local rewards = Config.Rewards[rewardIndex].Rewards
        self._services.RewardService:GiveMultipleRewards(player, rewards)
    end)

    Players.PlayerAdded:Connect(function(addedPlayer: Player)
        if not addedPlayer:GetAttribute("IsLoaded") then
            addedPlayer:GetAttributeChangedSignal("IsLoaded"):Wait()
        end

        local function spawnFreeRewardTask(player: Player)
            FreeSpinTimerUpdated:FireClient(player, os.time())

            self._givingTasks[player] = task.spawn(function()
                task.wait(Config.FreeSpinRewardTime)

                if not player then
                    self._givingTasks[player] = nil

                    return
                end

                local spinsAmount = player:GetAttribute("SpinsAmount") or 0
                player:SetAttribute("SpinsAmount", spinsAmount + 1)
                self._givingTasks[player] = nil
                spawnFreeRewardTask(player)
            end)
        end

        spawnFreeRewardTask(addedPlayer)
    end)

    Players.PlayerRemoving:Connect(function(player: Player)
        if self._pendingRewards[player] then
            self._pendingRewards[player] = nil
        end

        if self._givingTasks[player] then
            task.cancel(self._givingTasks[player])
            self._givingTasks[player] = nil
        end

        if self._debounces[player] then
            self._debounces[player] = nil
        end
    end)
end

function SpinService.new()
	local self = setmetatable(SpinService, {__index = ServiceTemplate})
    self._pendingRewards = {}
    self._givingTasks = {}
    self._debounces = {}

	return self
end

return SpinService