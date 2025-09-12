local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ConsumablesConfig = require(ReplicatedStorage.Configs.ConsumablesConfig)
local ConsumableFrame = require(script.ConsumableFrame)

local Consumables = {}

local function onSaveLoaded(self, consumables)
    for _, consumableData in pairs(ConsumablesConfig.UiInfo) do
        local amount

        if not consumables[consumableData.Name] then
            warn(consumableData.Name .. "is not in save")
            amount = 0
        else
            amount = consumables[consumableData.Name]
        end

        local frame = self._prefab:Clone()
        frame.Parent = self._prefab.Parent
        frame.LayoutOrder = consumableData.LayoutOrder
        frame.Visible = true

        self._consumables[consumableData.Name] = ConsumableFrame.new(frame, self._controllers.ButtonsInteractionsConnector, consumableData, amount)
        self._controllers.TooltipsController:RegisterTooltip(frame.Icon, consumableData.TooltipInfo)
    end
end

function Consumables:Initialize()
    self._consumables = {}
    local inventory = self._controllers.InventoryController:GetInventory()

    if inventory then
        onSaveLoaded(self, inventory.Consumables)
    else
        self._controllers.InventoryController.Initialized:Subscribe(self, function(save: {any})
            onSaveLoaded(self, save.Consumables)
        end)
    end

    self._controllers.InventoryController.Updated:Subscribe(self, function(categoryName: string, itemName: string, newAmount: number)
        if categoryName ~= "Consumables" then return end

        if not self._consumables[itemName] then
            return warn("Frame for", itemName, "is not exist")
        end

        self._consumables[itemName]:ChangeAmount(newAmount)
    end)
end

function Consumables.new(frame: Frame, controllers, utils)
    local self = setmetatable({}, {__index = Consumables})
    self._prefab = frame.ItemTemplate
    self._controllers = controllers
    self._utils = utils
    self._frame = frame

    return self
end

return Consumables