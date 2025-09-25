local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProductRequested = ReplicatedStorage.Remotes.Monetization.DevProductRequested
local Requested = ReplicatedStorage.Remotes.Rebirth.Requested

local Configs = ReplicatedStorage.Configs
local DevProductsConfig = require(Configs.DevProductsConfig)
local RebirthConfig = require(Configs.RebirthConfig)

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local ProgressBar = require(ReplicatedStorage.Modules.UI.ProgressBar)

export type RebirthFrame = {
    new: (frame: Frame) -> RebirthFrame;

    _cashValueObject: IntValue;
    _rebirthsAmount: number;
    _progressBar: ProgressBar.Type;
    _player: Player;
    _frame: Frame;
} & ControllerTemplate.Type

local RebirthFrame = {} :: RebirthFrame

local function updateProgressBar(self: RebirthFrame)
    local price = RebirthConfig.Price.StartValue * (RebirthConfig.Price.Multiplier ^ self._rebirthsAmount)
    local priceText = self._utils.FormatNumber(price)

    local currentAmount = self._cashValueObject.Value
    local currentAmountText = self._utils.FormatNumber(currentAmount)

    self._progressBar.MaxValue = price
    self._progressBar:SetValue(currentAmount)
    self._progressBar:SetCustomText(`{currentAmountText}/{priceText}`)
end

local function updateInfoFrame(self: RebirthFrame)
    local infoFrame = self._frame.InfoFrame

    local beforeFrame: Frame = infoFrame.Before
    local beforeRebirthsLabel: TextLabel = beforeFrame.Rebirth.Label
    local beforeCashLabel: TextLabel = beforeFrame.Cash.Label

    local afterFrame: Frame = infoFrame.After
    local afterRebirthsLabel: TextLabel = afterFrame.Rebirth.Label
    local afterCashLabel: TextLabel = afterFrame.Cash.Label

    beforeRebirthsLabel.Text = tostring(self._rebirthsAmount)
    afterRebirthsLabel.Text = tostring(self._rebirthsAmount + 1)

    beforeCashLabel.Text = "X" .. tostring(RebirthConfig.Bonus.StartValue + (RebirthConfig.Bonus.Step * (self._rebirthsAmount - 1)))
    afterCashLabel.Text = "X" .. tostring(RebirthConfig.Bonus.StartValue + (RebirthConfig.Bonus.Step * (self._rebirthsAmount)))
end

function RebirthFrame:AfterPlayerLoaded(player: Player)
    self._player = player

    if not player:GetAttribute("RebirthsAmount") then
        player:GetAttributeChangedSignal("RebirthsAmount"):Wait()
    end

    self._progressBar = ProgressBar.new(self._frame.ProgressFrame.ProgressBar, 1, true)
    self._cashValueObject = player:WaitForChild("Currencies"):WaitForChild("Cash")
    self._rebirthsAmount = player:GetAttribute("RebirthsAmount")
    updateProgressBar(self)
    updateInfoFrame(self)

    self._cashValueObject.Changed:Connect(function()
        updateProgressBar(self)
    end)

    player:GetAttributeChangedSignal("RebirthsAmount"):Connect(function()
        self._rebirthsAmount = player:GetAttribute("RebirthsAmount")
        updateProgressBar(self)
        updateInfoFrame(self)
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.CloseButton, function()
        self._controllers.GuiController.RebirthGui:Disable()
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.Buttons.Rebirth, function()
        Requested:FireServer()
    end)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._frame.Buttons.Skip, function()
        DevProductRequested:FireServer(DevProductsConfig.Others.SkipRebirth)
    end)
end

function RebirthFrame.new(frame: Frame)
    local self = setmetatable(RebirthFrame, {__index = ControllerTemplate})
    self._frame = frame

    return self
end


return RebirthFrame