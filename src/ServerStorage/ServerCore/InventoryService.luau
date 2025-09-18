local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes.Inventory
local ItemUnlockAttempted = Remotes.ItemUnlockAttempted
local ItemEquipped = Remotes.ItemEquipped
local GetInventory = Remotes.GetInventory
local ItemAdded = Remotes.ItemAdded
local ConsumableUsed = Remotes.ConsumableUsed

local Assets = ReplicatedStorage.Assets
local BasketPivotWeld = Assets.Food.BasketPivotWeld
local Configs = ReplicatedStorage.Configs
local BasketsConfig = require(Configs.BasketsConfig)
local ConsumablesConfig = require(Configs.ConsumablesConfig)
local WingsConfig = require(Configs.WingsConfig)

local ServerTypes = require(script.Parent.Parent.ServerTypes)
local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local InventoryService = {} :: ServerTypes.InventoryService

local consumablesUsageFunctions = {
    CashPotion = function(self, player: Player)
        return self._services.BoostsService:TryAddTemporaryBoost(player, "CashPotion", ConsumablesConfig.Potions.CashPotion.BoostData)
    end;
    JumpPowerPotion = function(self, player: Player)
        return self._services.BoostsService:TryAddTemporaryBoost(player, "JumpPowerPotion", ConsumablesConfig.Potions.JumpPowerPotion.BoostData)
    end;
    WinsPotion = function(self, player: Player)
        return self._services.BoostsService:TryAddTemporaryBoost(player, "WinsPotion", ConsumablesConfig.Potions.WinsPotion.BoostData)
    end;
}

local function tryUseConsumable(self: ServerTypes.InventoryService, player: Player, categoryName: string, name: string)
    if not self._playersSaves[player] then return false end

    if (not self._playersSaves[player].Consumables[categoryName][name]) or (self._playersSaves[player].Consumables[categoryName][name] < 1) then
        self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "You don't have any of this item")

        return false
    end

    if consumablesUsageFunctions[name](self, player) then
        self._playersSaves[player].Consumables[categoryName][name] -= 1
        ConsumableUsed:FireClient(player, categoryName, name)

        return true
    else
        self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "Something went wrong while using this item")

        return false
    end
end

local unlockingFunctions = {
    Baskets = function(self: ServerTypes.InventoryService, player: Player, itemName: string)
        local basketInfo = BasketsConfig.Items[itemName]

        if basketInfo.ProductId then
            self._services.Monetization:PromptProduct(player, basketInfo.ProductId)
        else
            if self._services.SoftCurrencyService:TrySpentCurrency(player, "Cash", basketInfo.PriceInCash, "Gameplay", itemName) then
                self:TryAddItem(player, "Equipment", "Baskets", itemName)
            end
        end
    end;

    Wings = function(self: ServerTypes.InventoryService, player: Player, itemName: string)
        local wingsInfo = WingsConfig.Wings[itemName]

        if wingsInfo.ProductId then
            self._services.Monetization:PromptProduct(player, wingsInfo.ProductId)
        else
            if self._services.SoftCurrencyService:TrySpentCurrency(player, "Cash", wingsInfo.PriceInCash, "Gameplay", itemName) then
                self:TryAddItem(player, "Equipment", "Wings", itemName)
            end
        end
    end;
}

local equipFunctions = {
    Baskets = function(self: ServerTypes.InventoryService, player: Player, itemName: string)
        local character = player.Character or player.CharacterAdded:Wait()

        if not self._equippedItemModels[player].BasketPivot then
            local basketPivot = Instance.new("Part")
            basketPivot.Size = Vector3.one * .1
            basketPivot.CanCollide = false
            basketPivot.Transparency = 1
            basketPivot.Name = "BasketPivot"
            self._equippedItemModels[player].BasketPivot = basketPivot
            self._equippedItemModels[player].BasketPivot.Parent = character

            local weld = BasketPivotWeld:Clone()
            weld.Parent = basketPivot
            weld.Part0 = character:WaitForChild("RightHand")
            weld.Part1 = basketPivot
            weld.Enabled = true
        end

		if self._equippedItemModels[player].Basket then
			self._equippedItemModels[player].Basket:Destroy()
			self._equippedItemModels[player].Basket = nil
		end

        player.Equipment.Basket.Value = itemName;
		local model = Assets.Baskets[itemName]:Clone() :: Model

		local weld = Instance.new("Weld")
		weld.Parent = self._equippedItemModels[player].BasketPivot
		weld.Part0 = self._equippedItemModels[player].BasketPivot
		weld.Part1 = model.PrimaryPart
		weld.C1 = CFrame.fromEulerAnglesYXZ(0, 0, 0)

		model.Parent = character
        model.Name = "Basket"
		self._equippedItemModels[player].Basket = model
	end;

    Wings = function(self: ServerTypes.InventoryService, player: Player, itemName: string)
        local brainrotModel = self._services.BrainrotService:GetPlayerBrainrot(player)
        local wingsPivot = brainrotModel:FindFirstChild("WingsPivot")

		if self._equippedItemModels[player].Wings then
			self._equippedItemModels[player].Wings:Destroy()
			self._equippedItemModels[player].Wings = nil
		end

        player.Equipment.Wing.Value = itemName;
        local model = WingsConfig.Wings[itemName].Model:Clone() :: Model

		local weld = Instance.new("Weld")
		weld.Parent = model
		weld.Part0 = wingsPivot
		weld.Part1 = model.PrimaryPart
		weld.C1 = CFrame.fromEulerAnglesYXZ(0, 0, 0)

		model.Parent = wingsPivot
        model:PivotTo(wingsPivot.CFrame)
		self._equippedItemModels[player].Wings = model
	end;
}

local function validateSave(save)
    save = save or {}

    save.Consumables = save.Consumables or {
        Potions = {
            CashPotion = 0;
            JumpPowerPotion = 0;
            WinsPotion = 0;
        };
    }

	save.Equipment = save.Equipment or {}
    save.Equipment.Baskets = save.Equipment.Baskets or {Default = true}
    save.Equipment.Wings = save.Equipment.Wings or {}

    return save
end

local function onEquipmentChanged(player: Player)
    player:SetAttribute("FoodCapacity", BasketsConfig.Items[player.Equipment.Basket.Value].FoodCapacity)
end

local function isValidInventoryRequest(self: ServerTypes.InventoryService, player: Player, itemType: string, categoryName: string)
    if not self._playersSaves[player] then
        warn("Player", player, "has no save record")

        return false
    end

    if not self._playersSaves[player][itemType][categoryName] then
        warn("There is no category with name", categoryName, "in save table")

        return false
    end

    return true
end

function InventoryService:HasItem(player: Player, itemType, categoryName: string, itemName: string) : boolean
    if not isValidInventoryRequest(self, player, itemType, categoryName) then return false end

    return self._playersSaves[player][itemType][categoryName][itemName] ~= nil
end

function InventoryService:TryAddItem(player: Player, itemType: string, categoryName: string, itemName: string, amount: number?) : boolean
    if not isValidInventoryRequest(self, player, itemType, categoryName) then return false end

    if itemType == "Consumables" then
        local currentAmount = self._playersSaves[player].Consumables[categoryName][itemName] or 0
        self._playersSaves[player].Consumables[categoryName][itemName] = currentAmount + amount

        ItemAdded:FireClient(player, itemType, categoryName, itemName, amount)
    else
        if self:HasItem(player, itemType, categoryName, itemName) then return false end

        self._playersSaves[player][itemType][categoryName][itemName] = true
        ItemAdded:FireClient(player, itemType, categoryName, itemName)
    end

    return true
end

function InventoryService:ToggleWingsVisibility(player: Player, enable: boolean)
    if not self._equippedItemModels[player].Wings then return end

    local model = self._equippedItemModels[player].Wings
    local transparency = enable and 1 or 0

    for _, part in model:GetChildren() do
        if not part:IsA("Part") then continue end
        if part.Name == "Primary" then continue end

        part.Transparency = transparency
    end
end

function InventoryService:RestoreEquippedWings(player: Player)
    if player.Equipment.Wing and player.Equipment.Wing.Value ~= "" then
        equipFunctions["Wings"](self, player, player.Equipment.Wing.Value)
    end
end

function InventoryService:RestoreEquippedItems(player: Player)
    self._equippedItemModels[player].BasketPivot = nil

	for _, obj: StringValue in pairs(player.Equipment:GetChildren()) do
        if not obj.Value or obj.Value == "" then continue end

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

    local function isInDebounce(player: Player)
        if self._debounces[player] then return true end

        self._debounces[player] = true

        task.delay(.5, function()
            self._debounces[player] = nil
        end)

        return false
    end

    ItemEquipped.OnServerEvent:Connect(function(player: Player, categoryName: string, itemName: string)
        if self._debounces[player] then return end

        self._debounces[player] = true

        task.delay(.5, function()
            self._debounces[player] = nil
        end)

        if self:HasItem(player, "Equipment", categoryName, itemName) then
            equipFunctions[categoryName](self, player, itemName)
            onEquipmentChanged(player)
        end
    end)

    ItemUnlockAttempted.OnServerEvent:Connect(function(player: Player, categoryName: string, itemName: string)
        if self._debounces[player] then return end

        self._debounces[player] = true

        task.delay(.5, function()
            self._debounces[player] = nil
        end)

        if unlockingFunctions[categoryName] then
            unlockingFunctions[categoryName](self, player, itemName)
        end
    end)

    ConsumableUsed.OnServerEvent:Connect(function(player: Player, consumableName: string, categoryName: string)
        if isInDebounce(player) then return end

        if not self:HasItem(player, "Consumables", categoryName, consumableName) then return end

        tryUseConsumable(self, player, categoryName, consumableName)
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