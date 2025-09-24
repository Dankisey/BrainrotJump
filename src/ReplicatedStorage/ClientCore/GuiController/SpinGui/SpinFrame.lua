local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Spin
local FreeSpinTimerUpdated = Remotes.FreeSpinTimerUpdated
local Attempted = Remotes.Attempted
local Approved = Remotes.Approved
local Finished = Remotes.Finished
local Declined = Remotes.Declined

local Config = require(ReplicatedStorage.Configs.SpinConfig)
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local DevProducts = require(ReplicatedStorage.Configs.DevProductsConfig)
local DevProductRequested = ReplicatedStorage.Remotes.Monetization.DevProductRequested

local TweenService = game:GetService("TweenService")

local SpinFrame = {}

local DegreesPerSecond = 360 / Config.FullSpinTime
local robuxSign = ""

local AutoSpinInfo = {
    [true] = {
        StrokeColor = Color3.fromRGB(21, 81, 15);
        ImageId = "rbxassetid://81390608716518";
        Text = "Auto Spin (on)";
    };
    [false] = {
        StrokeColor = Color3.fromRGB(89, 2, 3);
        ImageId = "rbxassetid://97873563899005";
        Text = "Auto Spin (off)";
    };
}

local function updateAutoSpin(self, state: boolean)
    self._autoSpinButton.TextLabel.Stroke.Color = AutoSpinInfo[state].StrokeColor
    self._autoSpinButton.TextLabel.Text = AutoSpinInfo[state].Text
    self._autoSpinButton.Image = AutoSpinInfo[state].ImageId
    self._isAutoSpinEnabled = state
end

local function trySpin(self)
    local spinsAmount = self._player:GetAttribute("SpinsAmount") or 0

    if (not self._isSpinning) and spinsAmount > 0 then
        Attempted:FireServer()

        return true
    else
        return false
    end
end

local function doSpinAnimation(self, rewardIndex: number)
    self._isSpinning = true
    local fullSpinsAmount = self._random:NextInteger(Config.FullSpinsAmount.Min, Config.FullSpinsAmount.Max)

    while fullSpinsAmount > 0 do
        self._spinWheel.Rotation += DegreesPerSecond * task.wait()

        if self._spinWheel.Rotation >= 360 then
            self._spinWheel.Rotation -= 360
            fullSpinsAmount -= 1
        end
    end

    local targetRotation = self._random:NextNumber(self._sectionRotations[rewardIndex].Min, self._sectionRotations[rewardIndex].Max)
    local tweenInfo = TweenInfo.new((targetRotation / 360) * Config.FullSpinTime * 6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    local tween = TweenService:Create(self._spinWheel, tweenInfo, {Rotation = targetRotation})
    tween:Play()
    tween.Completed:Wait()
    task.wait(Config.RewardDelay)
    Finished:FireServer()
    self._isSpinning = false

    if self._isAutoSpinEnabled then
        task.wait(1)

        if not trySpin(self) then
            updateAutoSpin(self, false)
        end
    end
end

local function updateTimer(self, startTime)
    local endTime = startTime + Config.FreeSpinRewardTime
    local remainingTime = endTime - os.time()

    self.FreeSpinTimer:Reset()
    self.FreeSpinTimer:Start(remainingTime)
end

function SpinFrame:AfterPlayerLoaded(player: Player)
    self._autoSpinButton = self._frame.Bottom.AutoSpinButton
    updateAutoSpin(self, false)

    self._isSpinning = false
    self._player = player

    Declined.OnClientEvent:Connect(function()
        updateAutoSpin(self, false)
    end)

    Approved.OnClientEvent:Connect(function(rewardIndex: number)
        doSpinAnimation(self, rewardIndex)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.SpinWheel.SpinButton, function()
        trySpin(self)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.Bottom.AutoSpinButton, function()
        updateAutoSpin(self, trySpin(self))
    end)

    local spinsAmount = player:GetAttribute("SpinsAmount") or 0
    local spinButton = self._frame.Bottom.SpinButton
    spinButton.CounterLabel.Text = "X" .. spinsAmount

    player:GetAttributeChangedSignal("SpinsAmount"):Connect(function()
        spinsAmount = player:GetAttribute("SpinsAmount") or 0
        spinButton.CounterLabel.Text = "X" .. spinsAmount
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(spinButton, function()
        trySpin(self)
    end)

    for amount, productId in pairs(DevProducts.Spins) do
        local button = self._frame.Products:WaitForChild(amount, 10)

        if not button then
            warn("button with name", amount, "is not a part of Products frame (SpinGui)")
            continue
        end

        local productInfo = self._utils.TryGetProductInfo(productId, Enum.InfoType.Product)
        local priceLabel

        if productInfo and productInfo.PriceInRobux then
            priceLabel = productInfo.PriceInRobux .. robuxSign
        else
            priceLabel = "???" .. robuxSign
        end

        button.CostLabel.Text = priceLabel

        self._controllers.ButtonsInteractionsConnector:ConnectButton(button, function()
            DevProductRequested:FireServer(productId)
        end)
    end

    self._controllers.GuiController.SpinGui.Gui:GetPropertyChangedSignal("Enabled"):Connect(function()
        if self._controllers.GuiController.SpinGui.Gui.Enabled == false then
            updateAutoSpin(self, false)
        end
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.CloseButton, function()
        self._controllers.GuiController.SpinGui:Disable()
    end)
end

function SpinFrame:Initialize()
    self._spinWheel = self._frame:WaitForChild("SpinWheel")
    self._sectionRotations = table.create(8)

    for i = 1, 8 do
        local sectionCenter = 22.5 + 45 * (i - 1)
        local minRotation = sectionCenter - 20.5
        local maxRotation = sectionCenter + 20.5

        table.insert(self._sectionRotations, {
            Min = minRotation;
            Max = maxRotation;
        })

        local config = Config.Rewards[i]
        local section = self._spinWheel:WaitForChild(i)
        section.Icon.Image = config.Icon
        section.NameLabel.Text = config.ShowingInfo
        section.ChanceLabel.Text = math.round(config.Chance * 100) .. "%"
        self._controllers.TooltipsController:RegisterTooltip(section.Icon, config.TooltipInfo)
    end

    local timerLabel = self._frame:WaitForChild("Bottom"):WaitForChild("Timer"):WaitForChild("Label") :: TextLabel
    self.FreeSpinTimer = self._utils.Timer.new()

    self.FreeSpinTimer.Updated:Subscribe(self, function(leftTime)
        timerLabel.Text = self._utils.FormatTime(leftTime, 2)
    end)

    updateTimer(self, os.time())

    FreeSpinTimerUpdated.OnClientEvent:Connect(function(startTime)
        updateTimer(self, startTime)
    end)
end

function SpinFrame.new(frame: Frame)
    local self = setmetatable(SpinFrame, {__index = ControllerTemplate})
    self._random = Random.new()
    self._frame = frame

    return self
end

return SpinFrame