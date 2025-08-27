local random = Random.new()

local function getChancedRewardIndex(rewardsConfig)
	local randomNumber = random:NextNumber()
	local rewardIndex = nil

	for i, reward in pairs(rewardsConfig) do
		rewardIndex = i

		if randomNumber - reward.Chance <= 0 then
			break
		end

		randomNumber -= reward.Chance
	end

	return rewardIndex
end

return getChancedRewardIndex
