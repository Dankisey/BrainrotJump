local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProgressBar = require(ReplicatedStorage.Modules.UI.ProgressBar)
local AchievementsConfig = require(ReplicatedStorage.Configs.AchievementsConfig)
local Remotes = ReplicatedStorage.Remotes.Achievements
local AchievementRewardRequested = Remotes.AchievementRewardRequested :: RemoteEvent

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local AchievementsFrame = {}

local function toggleCompletitionStatusElements(self, frame, elementToActivate: string)
    for _, elementName in self._completitionStatusElements do
        frame[elementName].Visible = elementName == elementToActivate
    end
end

local function updateCompletitionStatus(self, index, data)
    local frame = self._achievementFrames[index]
    if data.IsCompleted and not data.IsClaimed then
        toggleCompletitionStatusElements(self, frame, "ClaimButton")
        self._progressBars[index]:SetValue(AchievementsConfig[index].Goal)

        self._controllers.ButtonsInteractionsConnector:ConnectButton(frame.ClaimButton, function()
            AchievementRewardRequested:FireServer(index)
        end)

        self._controllers.GuiController.MainGui.LeftSide.AchievementsPin:TurnOn()
    elseif data.IsClaimed then
        toggleCompletitionStatusElements(self, frame, "Claimed")
        self._progressBars[index]:SetValue(AchievementsConfig[index].Goal)

        local canTurnInfopinOff = true

        for _, achievementFrame in self._achievementFrames do
            if achievementFrame.ClaimButton.Visible then
                canTurnInfopinOff = false
                break
            end
        end

        if canTurnInfopinOff then
            self._controllers.GuiController.MainGui.LeftSide.AchievementsPin:TurnOff()
        end
    else
        toggleCompletitionStatusElements(self, frame, "Percentage")
        local percentage = math.round(data.CurrentValue / AchievementsConfig[index].Goal * 100)
        frame.Percentage.Text = percentage .. "%"

        self._progressBars[index]:SetValue(data.CurrentValue)
    end
end

function AchievementsFrame:Initialize()
    self._closeButton = self._frame.CloseButton

    local function close()
		self._controllers.GuiController.AchievementsGui:Disable()
	end

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._closeButton, close)

    self._completitionStatusElements = {"ClaimButton", "Claimed", "Percentage"}
    self._scroll = self._frame.Scroll
    self._template = self._scroll.Template

    self._achievementFrames = {}
    self._progressBars = {}

    for index, achievement in AchievementsConfig do
        local frame = self._template:Clone()
        frame.Name = index
        frame.GoalText.Text = achievement.GoalText

        local reward = frame.Reward
        reward.ItemName.Text = achievement.RewardScreenName
        reward.Quantity.Text = "x" .. self._utils.FormatNumber(achievement.RewardShowAmount)
        reward.Icon.Image = achievement.RewardIcon

        frame.Visible = true
        frame.Parent = self._scroll
        frame.LayoutOrder = achievement.LayoutOrder

        self._achievementFrames[index] = frame
        self._progressBars[index] = ProgressBar.new(frame.ProgressBarGroup.ProgressBar, achievement.Goal, false)
    end

    self._controllers.AchievementsController.AchievementInfoUpdated:Subscribe(self, function(index: number, data: number)
        updateCompletitionStatus(self, index, data)
    end)
end

function AchievementsFrame.new(frame: Frame)
    local self = setmetatable(AchievementsFrame, {__index = ControllerTemplate})
    self._frame = frame

    return self
end

return AchievementsFrame