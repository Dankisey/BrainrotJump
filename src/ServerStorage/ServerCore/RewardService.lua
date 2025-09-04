local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local PopupRequested = Remotes.UI.PopupRequested
local SoundRequested = Remotes.SoundRequested

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)
local RewardService = {} :: ServiceTemplate.Type

local rewardsFunctions = {
	Food = function(player: Player, amount: number, self: ServiceTemplate.Type)
		player.Currencies.Food.Value += amount
		player.TotalStats.TotalFood.Value += amount
	end;

	Pet = function(player: Player, petName: string, self: ServiceTemplate.Type)
		self._services.PetService:GivePet(player, petName, "Normal")
	end;
}

function RewardService:GiveMultipleRewards(player: Player, rewards)
	for functionName, data in pairs(rewards) do
		if not rewardsFunctions[functionName] then
			warn("There is not reward function with name ".. functionName)

			continue
		end

		local success, value = pcall(rewardsFunctions[functionName], player, data, self)

		if not success then
			warn("An error occured while giving rewards: " .. tostring(value))
		end
	end
end

function RewardService:GiveReward(player: Player, rewardInfo: {FunctionName: string, Data: any})
	if not rewardsFunctions[rewardInfo.FunctionName] then
		warn("There is not reward function with name ".. rewardInfo.FunctionName)

		return
	end

	rewardsFunctions[rewardInfo.FunctionName](player, rewardInfo.Data, self)
end

function RewardService.new()
	local self = setmetatable(RewardService, {__index = ServiceTemplate})

	return self
end

return RewardService