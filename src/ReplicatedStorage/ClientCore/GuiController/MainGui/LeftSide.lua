local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Counter = require(ReplicatedStorage.Modules.UI.Counter)
local InfoPin = require(ReplicatedStorage.Modules.UI.InfoPin)
local BrainrotFed = ReplicatedStorage.Remotes.Brainrots.BrainrotFed :: RemoteEvent
local TweenService = game:GetService("TweenService")

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local LeftSide = {} :: ControllerTemplate.Type

local function updateFoodCounter(self: ControllerTemplate.Type)
    self._foodCounterLabel.Text = string.format("%s/%s", self._utils.FormatNumber(self._foodValueObject.Value), self._utils.FormatNumber(self._currentFoodCapacity))
    local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenUp = TweenService:Create(self._foodCounterLabel, tweenInfo, {Size = UDim2.fromScale(self._foodLabelSize.X + .1, self._foodLabelSize.Y + .1)})
    local tweenDown = TweenService:Create(self._foodCounterLabel, tweenInfo, {Size = UDim2.fromScale(self._foodLabelSize.X, self._foodLabelSize.Y)})

    tweenUp:Play()
    tweenUp.Completed:Wait()
	tweenDown:Play()
    tweenDown.Completed:Wait()
end

function LeftSide:AfterPlayerLoaded(player: Player)
    self._foodValueObject = player:WaitForChild("Currencies"):WaitForChild("Food")
    self._currentFoodCapacity = player:GetAttribute("FoodCapacity") or 1
    self._foodCounterLabel = self._frame.FoodCounter.CounterLabel
    self._foodLabelSize = Vector2.new(self._foodCounterLabel.Size.X.Scale, self._foodCounterLabel.Size.Y.Scale)

    local cash = player:WaitForChild("Currencies"):WaitForChild("Cash") :: IntValue
	self.Counters.Cash = Counter.new(self._frame.CashCounter, cash)

    player:GetAttributeChangedSignal("FoodCapacity"):Connect(function()
        self._currentFoodCapacity = player:GetAttribute("FoodCapacity")
        updateFoodCounter(self)
    end)

    self._controllers.FoodCounter.Disabled:Subscribe(self, function()
        updateFoodCounter(self)
    end)

    BrainrotFed.OnClientEvent:Connect(function()
        updateFoodCounter(self)
    end)

    updateFoodCounter(self)
end

function LeftSide:Initialize()
    local buttons = self._frame.Buttons

	self._controllers.ButtonsInteractionsConnector:ConnectButton(buttons.SacksButton, function()
		self._controllers.GuiController.SacksGui:Enable(true)
    end)

    self.PetsButton = buttons.PetsButton

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self.PetsButton, function()
        self._controllers.GuiController.PetsGui:Enable(true)
        self._controllers.GuiController.PetsGui.PetsFrame:ChangeCategory("Pets")

        -- if self._controllers.TutorialController.CurrentStep == 5 then
        --     self._controllers.TutorialController:CompleteStep()
        -- end
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(buttons.InventoryButton, function()
        self._controllers.GuiController.InventoryGui:Enable(true)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(buttons.UpgradesButton, function()
        self._controllers.GuiController.UpgradesGui:Enable(true)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(buttons.DailyButton, function()
        self._controllers.GuiController.DailyRewardsGui:Enable(true)
    end)

    self.TimeRewardsButton = buttons.TimeRewardsButton

    self.TimeRewardsPin = InfoPin.new(self.TimeRewardsButton.Icon.Pin)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self.TimeRewardsButton, function()
        self._controllers.GuiController.TimeRewardsGui:Enable(true)
        self.TimeRewardsPin:TurnOff()
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(buttons.WingsButton, function()
        self._controllers.GuiController.WingsGui:Enable(true)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(buttons.ShopButton, function()
        self._controllers.GuiController.RobuxShopGui:Enable(true)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(buttons.RebirthButton, function()
        self._controllers.GuiController.RebirthGui:Enable(true)
    end)
end

function LeftSide.new(frame: Frame)
    local self = setmetatable(LeftSide, {__index = ControllerTemplate})
    self._frame = frame
    self.Counters = {}

    return self
end

return LeftSide