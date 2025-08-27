local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Inventory
local ItemEquipped = Remotes.ItemEquipped
local GetInventory = Remotes.GetInventory
local ItemAdded = Remotes.ItemAdded

local Assets = ReplicatedStorage.Assets
local Configs = ReplicatedStorage.Configs
local BasketsConfig = require(Configs.BasketsConfig)

local ServerTypes = require(script.Parent.Parent.ServerTypes)
local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local InventoryService = {} :: ServerTypes.InventoryService

local equipFunctions = {
    Baskets = function(self: ServerTypes.InventoryService, player: Player, itemName: string)
		if self._equippedItemModels[player].Basket then
			self._equippedItemModels[player].Basket:Destroy()
			self._equippedItemModels[player].Basket = nil
		end

        player.Equipment.Basket.Value = itemName;
		local character = player.Character or player.CharacterAdded:Wait()
		local torso = character:WaitForChild("UpperTorso")
		local model = Assets.Baskets[itemName]:Clone() :: Model

		local weld = Instance.new("Weld")
		weld.Parent = model.PrimaryPart
		weld.Part0 = model.PrimaryPart
		weld.Part1 = torso
		weld.C1 = CFrame.new(0, -.6, -2)

		model.Parent = character
		self._equippedItemModels[player].Basket = model
	end;
}

local function validateSave(save)
    save = save or {}

	save.Equipment = save.Equipment or {}
    save.Equipment.Baskets = save.Equipment.Baskets or {"Default"}

    return save
end

local function onEquipmentChanged(player: Player)
    player:SetAttribute("CollectingRadius", 20)
    player:SetAttribute("FoodCapacity", BasketsConfig.Items[player.Equipment.Basket.Value].FoodCapacity)
end

local function isValidInventoryRequest(self: ServerTypes.InventoryService, player: Player, categoryName: string)
    if not self._playersSaves[player] then
        warn("Player", player, "has no save record")

        return false
    end

    if not self._playersSaves[player].Equipment[categoryName] then
        warn("There is no category with name", categoryName, "in save table")

        return false
    end

    return true
end

function InventoryService:HasItem(player: Player, categoryName: string, itemName: string) : boolean
    if not isValidInventoryRequest(self, player, categoryName) then return false end

    return self._playersSaves[player].Equipment[categoryName][itemName] ~= nil
end

function InventoryService:TryAddItem(player: Player, categoryName: string, itemName: string) : boolean
    if not isValidInventoryRequest(self, player, categoryName) then return false end

    if self:HasItem(player, categoryName, itemName) then return false end

    self._playersSaves[player].Equipment[categoryName][itemName] = true
    ItemAdded:FireClient(player, categoryName, itemName)

    return true
end

function InventoryService:RestoreEquippedItems(player: Player)
	for _, obj: StringValue in pairs(player.Equipment:GetChildren()) do
		equipFunctions[obj.Name .. "s"](self, player, obj.Value)
	end
end

function InventoryService:LoadSave(player: Player, savedInventory)
    self._playersSaves[player] = validateSave(savedInventory)
    self._equippedItemModels[player] = {}
    self:RestoreEquippedItems(player)
    onEquipmentChanged(player)
end

function InventoryService:UnloadSave(player: Player)
    local save = self._playersSaves[player]
    self._equippedItemModels[player] = nil
    self._playersSaves[player] = nil

    return save
end

function InventoryService:Initialize()
    GetInventory.OnServerInvoke = function(player: Player)
        while not self._playersSaves[player] do
            task.wait()
        end

        return self._playersSaves[player]
    end

    ItemEquipped.OnServerEvent:Connect(function(player: Player, categoryName: string, itemName: string)
        if self._debounces[player] then return end

        self._debounces[player] = true

        if self:HasItem(player, categoryName, itemName) then
            equipFunctions[categoryName](self, player, itemName)
            onEquipmentChanged(player)
        end

        task.delay(.5, function()
            self._debounces[player] = nil
        end)
    end)
end

function InventoryService.new()
	local self = setmetatable(InventoryService, {__index = ServiceTemplate})
    self._equippedItemModels = {}
    self._playersSaves = {}
    self._debounces = {}

    return self
end

return InventoryService