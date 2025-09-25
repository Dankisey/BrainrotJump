local RewardFrame = {}

local function initialize(self)
	self.Button:WaitForChild("AmountLabel").Text = self._config.ShowingInfo
	self.Button:WaitForChild("RewardImage").Image = self._config.Icon
    self._claimedMask = self.Button:WaitForChild("ClaimedMask")
    self._claimMask = self.Button:WaitForChild("ClaimMask")
end

function RewardFrame:SetClaimedStatus(enabled: boolean)
    self._claimedMask.Visible = enabled
end

function RewardFrame:SetClaimMask(enabled: boolean)
    self._claimMask.Visible = enabled
end

function RewardFrame.new(frame: Frame, rewardConfig)
	local self = setmetatable({}, {__index = RewardFrame})
    self.Button = frame:WaitForChild("Button")
    self._config = rewardConfig
	self._frame = frame
    initialize(self)

	return self
end

return RewardFrame