local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BrainrotFed = ReplicatedStorage.Remotes.Brainrots.BrainrotFed :: RemoteEvent
local TweenService = game:GetService("TweenService")

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local LeftSide = {} :: ControllerTemplate.Type

local function updateFoodCounter(self: ControllerTemplate.Type)
    self._foodCounterLabel.Text = string.format("%s/%s", self._utils.FormatNumber(self._foodValueObject.Value), self._utils.FormatNumber(self._currentFoodCapacity))
    local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenUp = TweenService:Create(self._foodCounterLabel, tweenInfo, {Size = UDim2.fromScale(.8, 1.1)})
    local tweenDown = TweenService:Create(self._foodCounterLabel, tweenInfo, {Size = UDim2.fromScale(.7, 1)})

    tweenUp:Play()
    tweenUp.Completed:Wait()
	tweenDown:Play()
    tweenDown.Completed:Wait()
end

function LeftSide:AfterPlayerLoaded(player: Player)
    self._foodValueObject = player:WaitForChild("Currencies"):WaitForChild("Food")
    self._currentFoodCapacity = player:GetAttribute("FoodCapacity") or 1
    self._foodCounterLabel = self._frame.FoodCounter.CounterLabel

    local buttons = self._frame.Buttons

    self._controllers.ButtonsInteractionsConnector:ConnectButton(buttons.BasketsButton, function()
        self._controllers.GuiController.BasketsGui:Enable(true)
    end)

    self.PetsButton = buttons.PetsButton

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self.PetsButton, function()
        self._controllers.GuiController.PetsGui:Enable(true)
        self._controllers.GuiController.PetsGui.PetsFrame:ChangeCategory("Pets")

        -- if self._controllers.TutorialController.CurrentStep == 5 then
        --     self._controllers.TutorialController:CompleteStep()
        -- end
    end)

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

function LeftSide.new(frame: Frame)
    local self = setmetatable(LeftSide, {__index = ControllerTemplate})
    self._frame = frame

    return self
end

return LeftSide