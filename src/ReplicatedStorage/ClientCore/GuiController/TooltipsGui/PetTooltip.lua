local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local PetTooltip = {}

function PetTooltip:Initialize()
    self._controllers.TooltipsController.PetTooltipActivated:Subscribe(self, function(activationObject: GuiObject, petName: string, isGold: boolean, isShiny: boolean)
        self._currentObject = activationObject
        self._rarity.BackgroundColor3 = PetsConfig.RarityColors[PetsConfig.Pets[petName].Rarity]
        self._rarity.TextLabel.Text = PetsConfig.Pets[petName].Rarity

        local coinsMultiplier = PetsConfig.Pets[petName].CashMultiplier
        local powerMultiplier = PetsConfig.Pets[petName].WinsMultiplier

        if isGold then
            coinsMultiplier *= PetsConfig.Pets[petName].GoldStatsMultiplier
            powerMultiplier *= PetsConfig.Pets[petName].GoldStatsMultiplier
            petName = petName .. " Gold"
            self._petName.TextColor3 = PetsConfig.TextColors.Gold
        elseif isShiny then
            coinsMultiplier *= PetsConfig.Pets[petName].ShinyStatsMultiplier
            powerMultiplier *= PetsConfig.Pets[petName].ShinyStatsMultiplier
            petName = petName .. " Shiny"
            self._petName.TextColor3 = PetsConfig.TextColors.Shiny
        end

        self._petName.Text = petName
        self._power.TextLabel.Text = "x" .. string.format("%.1f", powerMultiplier)
        self._coins.TextLabel.Text = "x" .. string.format("%.1f", coinsMultiplier)
        self._frame.Visible = true
    end)

    self._controllers.TooltipsController.PetTooltipDisabled:Subscribe(self, function(activationObject: GuiObject)
        if self._currentObject ~= activationObject then return end

        self._frame.Visible = false
        self._currentObject = nil
    end)

    RunService.Heartbeat:Connect(function()
        if not self._currentObject then return end

        local mousePosition = UserInputService:GetMouseLocation()
        local framePosition = Vector2.new(mousePosition.X / self._gui.AbsoluteSize.X, mousePosition.Y / self._gui.AbsoluteSize.Y)
        framePosition = UDim2.fromScale(framePosition.X, framePosition.Y)

        local xAnchorPoint, yAnchorPoint
        xAnchorPoint = if mousePosition.X + self._frameSize.X + 10 >= self._gui.AbsoluteSize.X then 1 else 0
        yAnchorPoint = if mousePosition.Y + self._frameSize.Y + 10 >= self._gui.AbsoluteSize.Y then 1 else 0

        self._frame.AnchorPoint = Vector2.new(xAnchorPoint, yAnchorPoint)
        self._frame.Position = framePosition
    end)
end

function PetTooltip.new(frame: Frame)
    local self = setmetatable(PetTooltip, {__index = ControllerTemplate})
    self._frameSize = frame.AbsoluteSize
    self._petName = frame.PetName.TextLabel
    self._currentObject = nil
    self._gui = frame.Parent
    self._frame = frame

    local infoFrame = frame.Background.InfoFrame
    self._rarity = infoFrame.Rarity
    self._power = infoFrame.Power
    self._coins = infoFrame.Coins

    return self
end

return PetTooltip