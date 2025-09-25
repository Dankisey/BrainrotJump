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

	Wins = function(player: Player, amount: number, self: ServiceTemplate.Type)
		player.Currencies.Wins.Value += amount
		player.TotalStats.TotalWins.Value += amount
	end;

	Cash = function(player: Player, data: {any}, self: ServiceTemplate.Type)
		player.Currencies.Cash.Value += data.Amount
		self._services.Analytics:LogCurrencyIncome(player, "Cash", data.Amount, data.TransactionType, data.Sku)
		player.TotalStats.TotalCash.Value += data.Amount
		SoundRequested:FireClient(player, self._configs.SoundNames.Coins)
	end;

	UpgradePoints = function(player: Player, amount: number, self: ServiceTemplate.Type)
		player.Currencies.UpgradePoints.Value += amount
	end;

	Pet = function(player: Player, petName: string, self: ServiceTemplate.Type)
		self._services.PetService:GivePet(player, petName, "Normal")
	end;

	Egg = function(player: Player, eggName: string, self: ServiceTemplate.Type)
		if not self._services.PetService:CheckAvailableStorage(player, 1) then
			return false
		end

		self._services.HatchEggService:OpenEgg(player, eggName, false, false)
	end;

	Potions = function(player: Player, data: {[string]: number}, self: ServiceTemplate.Type)
		task.spawn(function()
			for potionName: string, amount: number in pairs(data) do
				self._services.InventoryService:TryAddItem(player, "Consumables", "Potions", potionName, amount)
				task.wait(.5)
			end
		end)
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