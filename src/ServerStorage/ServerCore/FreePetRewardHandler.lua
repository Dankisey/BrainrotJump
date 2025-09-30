local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.FreePet
local TimerUpdated = Remotes.TimerUpdated
local Redeemed = Remotes.Redeemed
local RedeemRequested = Remotes.RedeemRequested
local FreePetConfig = require(ReplicatedStorage.Configs.FreePetConfig)

local Players = game:GetService("Players")

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local FreePetRewardHandler = {}

local function startTimer(self, player)
    self._playersTimeCounters[player] = task.spawn(function()
        local playtime = 0

        while task.wait(60) do
            playtime += 60

            TimerUpdated:FireClient(player, playtime)
            if playtime >= FreePetConfig.Time then
                player:SetAttribute("FreePetStatus", "RequirementsReached")
                break
            end
        end
    end)
end

function FreePetRewardHandler:Initialize()
    self._playersTimeCounters = {}

    Players.PlayerAdded:Connect(function(player)

        if player:GetAttribute("FreePetStatus") == nil then
            player:GetAttributeChangedSignal("FreePetStatus"):Wait()
        end

        local status = player:GetAttribute("FreePetStatus")

        if status == "Claimed" then
		    player:SetAttribute("FreePetStatus", "Claimed")
        elseif status == "RequirementsReached" then
            player:SetAttribute("FreePetStatus", "RequirementsReached")
            TimerUpdated:FireClient(player, FreePetConfig.Time)
	    else
		    player:SetAttribute("FreePetStatus", "NotReached")
            startTimer(self, player)
	    end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if self._playersTimeCounters[player] then
            task.cancel(self._playersTimeCounters[player])
            self._playersTimeCounters[player] = nil
        end
    end)

    RedeemRequested.OnServerEvent:Connect(function(player)
        local currentStatus = player:GetAttribute("FreePetStatus") or "Claimed"

	    if currentStatus == "Claimed" then
            self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "You've already claimed the reward")
            return
		end

        if currentStatus == "RequirementsReached" then
            self._services.RewardService:GiveMultipleRewards(player, FreePetConfig.Rewards)
        end

	    player:SetAttribute("FreePetStatus", "Claimed")
        Redeemed:FireClient(player)
    end)
end

function FreePetRewardHandler.new()
	return setmetatable(FreePetRewardHandler, {__index = ServiceTemplate})
end

return FreePetRewardHandler