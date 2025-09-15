local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Inventory
local ConsumableUsed = Remotes.ConsumableUsed

local ConsumableFrame = {}

local ActiveButtonImage = "rbxassetid://111561490440561"
local InactiveButtonImage = "rbxassetid://78015294234688"

local function initialize(self)
    self._frame.ItemName.Text = self._config.PublicName
    self._frame.Icon.Image = self._config.Icon
    self._frame.Name = self._config.Name
    self._useButton = self._frame.UseButton
    self._useButton.Image = InactiveButtonImage
    self._countLabel = self._useButton.CountLabel
    self:ChangeAmount(self._amount)
end

function ConsumableFrame:ChangeAmount(value: number)
    self._amount = math.max(value, 0)
    self._countLabel.Text = "X" .. self._amount

    if self._amount == 0 and self._isSubscribed then
        self._buttonsInteractionsConnector:DisconnectButton(self._useButton)
        self._useButton.Image = InactiveButtonImage
        self._isSubscribed = false

    elseif self._amount > 0 and self._isSubscribed == false then
        self._buttonsInteractionsConnector:ConnectButton(self._useButton, function()
            ConsumableUsed:FireServer(self._config.Name, self._config.ItemType)
        end)

        self._useButton.Image = ActiveButtonImage
        self._isSubscribed = true
    end
end

function ConsumableFrame.new(frame: Frame, buttonsInteractionsConnector, config, amount)
    local self = setmetatable({}, {__index = ConsumableFrame})
    self._buttonsInteractionsConnector = buttonsInteractionsConnector
    self._isSubscribed = false
    self._config = config
    self._amount = amount
    self._frame = frame
    initialize(self)

    return self
end

return ConsumableFrame