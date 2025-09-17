local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local GroupRewardRequested = Remotes.GroupRewardRequested

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local RewardsFrame = {}

local function disableButton(self)
    self._controllers.ButtonsInteractionsConnector:DisconnectButton(self._frame.ClaimButton)
	self._frame.ClaimButton.Image = "rbxassetid://79018637165895"
    self._frame.ClaimButton.TextLabel.Text = "Claimed"
end

function RewardsFrame:AfterPlayerLoaded(player: Player)
    if player:GetAttribute("IsGroupRewardClaimed") == nil then
        player:GetAttributeChangedSignal("IsGroupRewardClaimed"):Wait()
    end

    if player:GetAttribute("IsGroupRewardClaimed") then
        disableButton(self)
    else
        player:GetAttributeChangedSignal("IsGroupRewardClaimed"):Wait()
        disableButton(self)
    end
end

function RewardsFrame:Initialize()
    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.CloseButton, function()
        self._controllers.GuiController.GroupRewardsGui:Disable()
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.ClaimButton, function()
        GroupRewardRequested:FireServer()
    end)
end

function RewardsFrame.new(frame: Frame)
    local self = setmetatable(RewardsFrame, {__index = ControllerTemplate})
    self._frame = frame

    return self
end

return RewardsFrame