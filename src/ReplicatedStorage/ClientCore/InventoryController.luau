local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientTypes = require(ReplicatedStorage.Modules.ClientTypes)
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local Remotes = ReplicatedStorage.Remotes.Inventory
local ItemUnlockAttempted = Remotes.ItemUnlockAttempted
local GetInventory = Remotes.GetInventory
local ItemEquipped = Remotes.ItemEquipped
local ItemAdded = Remotes.ItemAdded

local InventoryController = {} :: ClientTypes.InventoryController

function InventoryController:RequestItemUnlocking(categoryName: string, itemName: string)
    ItemUnlockAttempted:FireServer(categoryName, itemName)
end

function InventoryController:TryEquipItem(categoryName: string, itemName: string) : boolean
    if not self:HasEquipment(categoryName, itemName) then
        warn("Trying to equip item that is not in inventory")
        return false
    end

    ItemEquipped:FireServer(categoryName, itemName)
end

function InventoryController:HasEquipment(categoryName: string, itemName: string) : boolean
    if (not self._inventory) then
        repeat task.wait() until self._inventory
    end

    if (not self._inventory.Equipment[categoryName]) then return false end

    return self._inventory.Equipment[categoryName][itemName] ~= nil
end

function InventoryController:Initialize()
    self._inventory = GetInventory:InvokeServer()

    ItemAdded.OnClientEvent:Connect(function(itemType: string, categoryName: string, itemName: string)
        if not self._inventory[itemType] then
            self._inventory[itemType] = {}
        end

        self._inventory[itemType][categoryName][itemName] = true
        self.Updated:Invoke()
    end)
end

function InventoryController:InjectUtils(utils)
    self.Updated = utils.Event.new()
    self._utils = utils
end

function InventoryController.new()
    local self = setmetatable(InventoryController, {__index = ControllerTemplate})

    return self
end

return InventoryController