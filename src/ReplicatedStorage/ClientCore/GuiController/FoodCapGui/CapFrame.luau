local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FoodCollectingConfig = require(ReplicatedStorage.Configs.FoodCollectingConfig)

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local CapFrame = {} :: ControllerTemplate.Type

function CapFrame:AfterPlayerLoaded()
    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.CloseButton, function()
        self._controllers.GuiController.FoodCapGui:Disable()
    end)

    self._controllers.FoodCollectingController.CapReached:Subscribe(self, function()
        if self._isDelayActive or self._controllers.GuiController.FoodCapGui.Gui.Enabled then return end

        self._delayLeftTime = FoodCollectingConfig.CapGuiShowingDelay
        self._isDelayActive = true

        self._controllers.GuiController.FoodCapGui:Enable(true)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.ActionsFrame.UpgradeButton, function()
		self._controllers.GuiController.SacksGui:Enable(true)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.ActionsFrame.FeedButton, function()
        local brainrotPoint = self._controllers.ZoneController:GetZone():WaitForChild("BrainrotPoint")
        self._controllers.GuideBeamController:CreateOrRedirectGuideBeam("Feed", brainrotPoint.Position, 18)
        self._controllers.GuiController.FoodCapGui:Disable()
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.GamepassFrame.PurchaseButton, function()
        print("Prompt pass here")
    end)

    task.spawn(function()
        while task.wait(1) do
            if self._controllers.GuiController.FoodCapGui.Gui.Enabled then continue end

            if self._isDelayActive and self._delayLeftTime <= 0 then
                self._isDelayActive = false
                self._delayLeftTime = 0
            end

            if not self._isDelayActive then continue end

            self._delayLeftTime -= 1
        end
    end)
end

function CapFrame.new(frame: Frame)
    local self = setmetatable(CapFrame, {__index = ControllerTemplate})
    self._isDelayActive = true
    self._delayLeftTime = 0
    self._frame = frame

    return self
end

return CapFrame