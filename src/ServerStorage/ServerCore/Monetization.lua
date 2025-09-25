local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Configs = ReplicatedStorage.Configs
local DevProductsConfig = require(Configs.DevProductsConfig)
local GamepassesConfig = require(Configs.GamepassesConfig)
local CurrenciesPacksConfig = require(Configs.CurrenciesPacksConfig)

local Remotes = ReplicatedStorage.Remotes.Monetization
local GamepassRequested = Remotes.GamepassRequested
local DevProductRequested = Remotes.DevProductRequested
local GamepassPurchased = Remotes.GamepassPurchased
local StarterPackPurchased = Remotes.StarterPackPurchased

local DataStoreService = game:GetService("DataStoreService")
local PurchasesHistoryStore = DataStoreService:GetDataStore("PurchasesHistory")

local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local Monetization = {} :: ServiceTemplate.Type

local productFunctions = {}
local gamepassFunctions = {}
local extraGamepassFunctions = {}

local function getPlayersHighestOpenWorld(self, player)
	local highestOpenWorld = 1

	for i = #self._configs.WorldsConfig.Worlds, 1, -1 do
		local unlocked = self._services.WorldsService:IsWorldUnlocked(player, i)

		if unlocked then
			highestOpenWorld = i
			break
		end
	end

	return highestOpenWorld
end

productFunctions[DevProductsConfig.Others.StarterPack] = function(self: ServiceTemplate.Type, player)
	self._services.RewardService:GiveMultipleRewards(player, self._configs.StarterPackConfig.Rewards)
	player:SetAttribute("StarterPackPurchased", true)
	StarterPackPurchased:FireClient(player)

	return true
end

productFunctions[DevProductsConfig.Others.SkipRebirth] = function(self: ServiceTemplate.Type, player)
	self._services.RebirthService:ApplyRebirthWithSkip(player)

	return true
end

function Monetization:ProcessReciept(receiptInfo)
	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local success, result, errorMessage
	local isPurchased = false

	success, errorMessage = pcall(function()
		isPurchased = PurchasesHistoryStore:GetAsync(playerProductKey)
	end)

	if success and isPurchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		error("Data store error:" .. errorMessage)
	end

	success, result = pcall(function()
		return PurchasesHistoryStore:UpdateAsync(playerProductKey, function(isAlreadyPurchased)
			if isAlreadyPurchased then return true end

			local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)

			if not player then return nil end

			local rewardFunction = productFunctions[receiptInfo.ProductId]
			local success2, result2 = pcall(rewardFunction, self, player, receiptInfo)

			if not success2 or not result2 then
				error("Failed to process a product purchase for ProductId: " .. tostring(receiptInfo.ProductId) .. " Player: " .. tostring(player) .. " Error: " .. tostring(result2))

				return nil
			end

			return true
		end)
	end)

	if not success then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	elseif result == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	else
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

extraGamepassFunctions[GamepassesConfig.Attributes.Plus1Pet.GamepassId] = function(self, player: Player)
	self._services.PetService:IncreaseEquippedPets(player, 1)

	return true
end

extraGamepassFunctions[GamepassesConfig.Attributes.Plus4Pet.GamepassId] = function(self, player: Player)
	self._services.PetService:IncreaseEquippedPets(player, 4)

	return true
end

extraGamepassFunctions[GamepassesConfig.Attributes.Plus8Pet.GamepassId] = function(self, player: Player)
	self._services.PetService:IncreaseEquippedPets(player, 8)

	return true
end

extraGamepassFunctions[GamepassesConfig.Attributes.Plus50Storage.GamepassId] = function(self, player: Player)
	self._services.PetService:IncreaseStorageSpace(player, 50)

	return true
end

extraGamepassFunctions[GamepassesConfig.Attributes.Plus100Storage.GamepassId] = function(self, player: Player)
	self._services.PetService:IncreaseStorageSpace(player, 100)

	return true
end

local function onGamepassPurchaseCompleted(self, player: Player, gamePassId: number)
	if not gamepassFunctions[gamePassId] then
		warn("Function for pass id " .. gamePassId .. " was not found!")

		return
	end

	gamepassFunctions[gamePassId](self, player, gamePassId)
end

function Monetization:PromptProduct(player: Player, productId: number)
	local canPurchaseRandomItems = player:GetAttribute("CanPurchaseRandomItems")

	if self._configs.DevelopersConfig[player.UserId] and RunService:IsStudio() == false then
		self._services.ServerMessagesSender:SendMessageToPlayer(player, "Default", "Developer purchase activated")
		productFunctions[productId](self, player, {ProductId = productId})
	else
		MarketplaceService:PromptProductPurchase(player, productId)
	end
end

function Monetization:PromptPass(player: Player, passId: number)
	if self._configs.DevelopersConfig[player.UserId] and RunService:IsStudio() == false then
		self._services.ServerMessagesSender:SendMessageToPlayer(player, "Default", "Developer purchase activated")
		gamepassFunctions[passId](self, player, passId)
	else
		MarketplaceService:PromptGamePassPurchase(player, passId)
	end
end

function Monetization:Initialize()
	for sackName, id in pairs(DevProductsConfig.Sacks) do
		productFunctions[id] = function(self: ServiceTemplate.Type, player: Player)
			return self._services.InventoryService:TryAddItem(player, "Equipment", "Sacks", sackName)
		end
	end

	for wingsName, id in pairs(DevProductsConfig.Wings) do
		productFunctions[id] = function(self: ServiceTemplate.Type, player: Player)
			return self._services.InventoryService:TryAddItem(player, "Equipment", "Wings", wingsName)
		end
	end

	for potionName, devProductId in DevProductsConfig.Potions do
		productFunctions[devProductId] = function(_, player: Player)
			self._services.RewardService:GiveReward(player, {FunctionName = "Potions", Data = {[potionName] = 1;}})

			return true
		end
	end

	for spinsAmount, devProductId in DevProductsConfig.Spins do
		productFunctions[devProductId] = function(_, player: Player)
			local currentSpins = player:GetAttribute("SpinsAmount") or 0
			player:SetAttribute("SpinsAmount", currentSpins + spinsAmount)

			return true
		end
	end

	for gamepass, info in GamepassesConfig.Attributes do
		gamepassFunctions[info.GamepassId] = function(_, player, gamePassId)
			if gamePassId == info.GamepassId then
				player:SetAttribute(info.AttributeName, true)

				if table.find(GamepassesConfig.AttributesWithExtraFunctions, gamepass) then
					extraGamepassFunctions[info.GamepassId](self, player)
				end

				GamepassPurchased:FireClient(player, info.AttributeName)
			end

			return true
		end
	end

	for eggId, devProductId in DevProductsConfig.Eggs do
		productFunctions[devProductId] = function(_, player: Player)
			if not self._services.WorldsService:IsWorldUnlocked(player, self._configs.EggConfig[eggId].World) then
				print("World for this egg is locked")
				return false
			end

			if not self._services.PetService:CheckAvailableStorage(player, 1) then
				return false
			end

			self._services.HatchEggService:OpenEgg(player, eggId, false, false)

			return true
		end
	end

	for eggId, devProductId in DevProductsConfig.TripleEggs do
		productFunctions[devProductId] = function(_, player: Player)
			if not self._services.WorldsService:IsWorldUnlocked(player, self._configs.EggConfig[eggId].World) then
				print("World for this egg is locked")
				return false
			end

			if not self._services.PetService:CheckAvailableStorage(player, 3) then
				return false
			end

			self._services.HatchEggService:OpenEgg(player, eggId, true, false)

			return true
		end
	end

	for packName, devProductId in DevProductsConfig.Cash do
		productFunctions[devProductId] = function(_, player: Player)
			local highestOpenWorld = getPlayersHighestOpenWorld(self, player)

			local cashAmount = CurrenciesPacksConfig.Cash[highestOpenWorld][packName]
			self._services.RewardService:GiveReward(player, {FunctionName = "Cash",
			Data = {
				Amount = cashAmount;
				TransactionType = Enum.AnalyticsEconomyTransactionType.IAP;
				Sku = "World " .. highestOpenWorld .. " " .. packName .. " CashPack";
			}})

			return true
		end
	end

	for packName, devProductId in DevProductsConfig.Wins do
		productFunctions[devProductId] = function(_, player: Player)
			local highestOpenWorld = getPlayersHighestOpenWorld(self, player)

			local winsAmount = CurrenciesPacksConfig.Wins[highestOpenWorld][packName]
			self._services.RewardService:GiveReward(player, {FunctionName = "Wins", Data = winsAmount})

			return true
		end
	end

	local function processReceipt(receiptInfo)
		self:ProcessReciept(receiptInfo)
	end

	MarketplaceService.ProcessReceipt = processReceipt

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player: Player, gamePassId: number, wasPurchased: boolean)
		if not wasPurchased then return end

		onGamepassPurchaseCompleted(self, player, gamePassId)
	end)

	DevProductRequested.OnServerEvent:Connect(function(player: Player, productId: number)
		self:PromptProduct(player, productId)
	end)

	GamepassRequested.OnServerEvent:Connect(function(player: Player, passId: number)
		self:PromptPass(player, passId)
	end)
end

function Monetization.new()
	local self = setmetatable(Monetization, {__index = ServiceTemplate})

	return self
end

return Monetization