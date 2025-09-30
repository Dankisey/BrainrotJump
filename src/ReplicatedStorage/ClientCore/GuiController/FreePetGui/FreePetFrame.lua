local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProgressBar = require(ReplicatedStorage.Modules.UI.ProgressBar)
local FreePetConfig = require(ReplicatedStorage.Configs.FreePetConfig)
local Remotes = ReplicatedStorage.Remotes.FreePet
local TimerUpdated = Remotes.TimerUpdated
local RedeemRequested = Remotes.RedeemRequested
local Redeemed = Remotes.Redeemed

local FreePetLobby = workspace:WaitForChild("FreePetLobby")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local FreePetFrame = {}

local function spawnBeam(self)
    local targetPosition = FreePetLobby.PromptPart.Position
    self._controllers.GuideBeamController:CreateOrRedirectGuideBeam("FreePet", targetPosition, 10)
end

function FreePetFrame:ShowCollectedVersion()
    self._redeemButton.Visible = false
    self._taskLabel.Text = "You've already collected the reward!"
    self._frame.ProgressBarGroup.Visible = false
    self._frame.Condition.Visible = false
end

function FreePetFrame:AfterPlayerLoaded(player: Player)
    self._player = player

    local currentRewardStatus = player:GetAttribute("FreePetStatus") or "NotReached"

    if currentRewardStatus == "Claimed" then
        self:ShowCollectedVersion()
        return
    elseif currentRewardStatus == "RequirementsReached" then
        self._progressBar:SetValue(FreePetConfig.Time)
        self._requirementsReached = true
        spawnBeam(self)
        self._progressBar:SetCustomText(math.round(FreePetConfig.Time / 60) .. "/" .. math.round(FreePetConfig.Time / 60))
    else
        self._progressBar:SetValue(0)
        self._progressBar:SetCustomText("0/" .. math.round(FreePetConfig.Time / 60))
    end

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._redeemButton, function()
        if self._requirementsReached then
            RedeemRequested:FireServer()
        else
            self._controllers.ClientMessagesSender:SendMessageToPlayer(self._configs.MessagesConfig.MessagesTypes.Error, "Requirements not reached yet!")
        end
    end)

    TimerUpdated.OnClientEvent:Connect(function(currentTimerValue: number)
        self._progressBar:SetValue(currentTimerValue)
        self._progressBar:SetCustomText(math.round(currentTimerValue / 60) .. "/" .. math.round(FreePetConfig.Time / 60))

        if currentTimerValue >= FreePetConfig.Time then
            self._requirementsReached = true
            spawnBeam(self)
        end
    end)

    Redeemed.OnClientEvent:Connect(function()
        self:ShowCollectedVersion()
    end)
end

function FreePetFrame:Initialize()
    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.CloseButton, function()
		self._controllers.GuiController.FreePetGui:Disable()
	end)

    self._redeemButton = self._frame.RedeemButton
    self._progressBar = ProgressBar.new(self._frame.ProgressBarGroup.ProgressBar, FreePetConfig.Time, true)
    self._taskLabel = self._frame.Task

    self._requirementsReached = false
end

function FreePetFrame.new(frame: Frame)
    local self = setmetatable(FreePetFrame, {__index = ControllerTemplate})
    self._frame = frame

    return self
end

return FreePetFrame