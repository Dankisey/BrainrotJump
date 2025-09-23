local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local TrailsConfig = require(ReplicatedStorage.Configs.TrailsConfig)
-- local TrailsFolder = ReplicatedStorage.Assets.Trails
-- local Remotes = ReplicatedStorage.Remotes.Trails
-- local TrailPurchaseAttempted = Remotes.TrailPurchaseAttempted

local GreenButton = "rbxassetid://81390608716518"
local RedButton = "rbxassetid://97873563899005"

local Trails = {}

local function toggleEquipButton(self, trailName)
    if self._equippedTrail == trailName then
        self._equipButton.TextLabel.Text = "Unequip"
        self._equipButton.Image = RedButton
    else
        self._equipButton.Image = GreenButton

        if not self._purchasedTrails then
            self._equipButton.TextLabel.Text = "Buy"

            return
        end

        if table.find(self._purchasedTrails, trailName) then
            self._equipButton.TextLabel.Text = "Equip"
        else
            self._equipButton.TextLabel.Text = "Buy"
        end
    end
end

function Trails:Initialize()
    -- self._chosenTrail = nil
    -- self._equippedTrail = self._controllers.TrailController:GetCurrentTrailName()

    -- self._itemTemplate = self._frame.Grid.ItemTemplate
    -- self._descriptionFrame = self._frame.Description

    -- self._equipButton = self._descriptionFrame.Equip

    -- self._multiplierSpeedFrame = self._descriptionFrame.MultiplierSpeed
    -- self._multiplierPowerFrame = self._descriptionFrame.MultiplierPower

    -- self._trailsCollection = {}

    -- for trailName, _ in TrailsConfig do
    --     self:CreateNewTrail(trailName)
    -- end

    -- self._descriptionFrame.Visible = false

    -- local inventory = self._controllers.InventoryController:GetInventory()

    -- if inventory then
    --     self._purchasedTrails = inventory.Trails
    -- else
    --     self._controllers.InventoryController.Initialized:Subscribe(self, function(save: {any})
    --         self._purchasedTrails = save.Trails
    --     end)
    -- end

    -- self._controllers.InventoryController.Updated:Subscribe(self, function(categoryName: string, itemName: string)
    --     if categoryName ~= "Trails" then return end

    --     if not self._purchasedTrails then return end

    --     if table.find(self._purchasedTrails, itemName) then return end

    --     table.insert(self._purchasedTrails, itemName)

    --     toggleEquipButton(self, self._chosenTrail)
    -- end)

    -- self._controllers.TrailController.TrailChanged:Subscribe(self, function(trailName)
    --     self._trailsCollection[self._equippedTrail].EquippedMark.Visible = false
    --     self._equippedTrail = trailName
    --     self._trailsCollection[trailName].EquippedMark.Visible = trailName ~= "Default"
    --     toggleEquipButton(self, self._chosenTrail)
    -- end)
end

--[[ function Trails:ShowDescription(trailName)
    if self._chosenTrail then
        self._previousChosen = self._chosenTrail

        if self._trailsCollection[self._previousChosen] then
            self._trailsCollection[self._previousChosen].Selected.Visible = false
        end
    end

    self._trailsCollection[trailName].Selected.Visible = true
    self._chosenTrail = trailName
    self._descriptionFrame.Visible = true

    self._controllers.ButtonsInteractionsConnector:DisconnectButton(self._equipButton)

    self._descriptionFrame.Icon.UIGradient.Color = TrailsFolder[trailName].Color
    self._descriptionFrame.ItemName.Text = trailName
    self._descriptionFrame.Cost.TextLabel.Text = self._utils.FormatNumber(TrailsConfig[trailName].Cost)

    self._multiplierSpeedFrame.TextLabel.Text = "+" .. TrailsConfig[trailName].SpeedBonus
    self._multiplierPowerFrame.TextLabel.Text = "x" .. TrailsConfig[trailName].PowerBonus

    toggleEquipButton(self, trailName)

    self._controllers.ButtonsInteractionsConnector:ConnectButton(self._equipButton, function()
        if not self._purchasedTrails then return end

        if table.find(self._purchasedTrails, trailName) then
            self._controllers.InventoryController:EquipTrail(trailName)
        else
            TrailPurchaseAttempted:FireServer(trailName)
        end
    end)
end

function Trails:CreateNewTrail(trailName)
    local newTrail = self._itemTemplate:Clone()
    newTrail.Parent = self._frame.Grid

    newTrail.Icon.UIGradient.Color = TrailsFolder[trailName].Color
    newTrail.EquippedMark.Visible = self._equippedTrail.Value == trailName
    newTrail.LayoutOrder = TrailsConfig[trailName].SpeedBonus
    newTrail.Visible = true

    self._trailsCollection[trailName] = newTrail

    local interactionButton = newTrail.InteractionButton

    local function interactionButtonCallback()
		self:ShowDescription(trailName)
    end

    self._controllers.ButtonsInteractionsConnector:ConnectButton(interactionButton, interactionButtonCallback)

    self._controllers.TooltipsController:RegisterTrailTooltip(newTrail, trailName)
end ]]

function Trails:TurnOn()
    self._frame.Visible = true
end

function Trails:TurnOff()
    self._frame.Visible = false
end

function Trails.new(frame: Frame, controllers, utils)
    local self = setmetatable({}, {__index = Trails})
    self._controllers = controllers
    self._frame = frame
    self._utils = utils

    return self
end

return Trails