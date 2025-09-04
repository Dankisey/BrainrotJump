local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EggConfig = require(ReplicatedStorage.Configs.EggConfig)
local PetsConfig = require(ReplicatedStorage.Configs.PetsConfig)

local Remotes = ReplicatedStorage.Remotes.Eggs
local EggHatchRequested = Remotes.EggHatchRequested
local AutoStopRequested = Remotes.AutoStopRequested
local EggOpened = Remotes.EggOpened

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local HatchEggService = {}

local function removePlayerFromDebounce(self, player)
	task.spawn(function()
		task.wait(3)
		self._debounces[player] = false
	end)
end

function HatchEggService:GetRandomPetFromEggWithLuck(player, eggName)
    local rng = Random.new()

    local eggConfig = EggConfig[eggName]

    if not eggConfig then
        warn("Egg config not found: " .. tostring(eggName))
        return nil
    end

    local playerLuck = 0

    if player:GetAttribute("UltraLuck") then
        playerLuck = 1000
    elseif player:GetAttribute("MegaLuck") then
        playerLuck = 700
    elseif player:GetAttribute("Luck") then
        playerLuck = 300
    end

	local bonusLuck = self._services.BoostsService:GetBonus(player, "Luck")
	playerLuck += bonusLuck

    local pets = eggConfig.Pets

    if not pets or next(pets) == nil then
        warn("No pets defined in egg: " .. eggName)
        return nil
    end

    local modifiedWeights = {}
    local totalWeight = 0

    for petName, baseWeight in pairs(pets) do
        local modifiedWeight = baseWeight
        local petData = PetsConfig.Pets[petName]

        if petData then
            if petData.rarity ~= "Common" then
                if petData.rarity == 'Legendary' then
                    modifiedWeight = modifiedWeight + (playerLuck * 0.5)
                else
                    modifiedWeight = modifiedWeight + playerLuck
                end
            else
                modifiedWeight = math.max(0.01, modifiedWeight - playerLuck)
            end
        end

        modifiedWeights[petName] = modifiedWeight
        totalWeight = totalWeight + modifiedWeight
    end

    local randomValue = rng:NextNumber(0, totalWeight)
    local cumulativeWeight = 0

    for petName, weight in pairs(modifiedWeights) do
        cumulativeWeight = cumulativeWeight + weight
        if randomValue <= cumulativeWeight then
            return petName
        end
    end

    warn("Failed to select pet properly, using fallback")
    return next(pets)
end

function HatchEggService:OpenEgg(player, eggId, isTriple, isAuto)
	player.Eggs[eggId].Value = true

	local amount = isTriple and 3 or 1
	local petsGiven = {}

	for i = 1, amount do
		local pet = self:GetRandomPetFromEggWithLuck(player, eggId)

		if not pet then continue end

		local petGiven = self._services.PetService:GivePet(player, pet)

		if not petGiven then continue end

		table.insert(petsGiven, pet)
	end

	if #petsGiven > 0 then
		EggOpened:FireClient(player, eggId, petsGiven)
		player.GlobalStats.Hatches.Value += #petsGiven
	end

	task.spawn(function()
		task.wait(3)
		self._debounces[player] = false

		if EggConfig[eggId].Currency == "Cash" and player:GetAttribute("AutoHatch") and isAuto then
			if self._stopQueue[player] then
				player:SetAttribute("IsInAutoHatching", false)
				self._stopQueue[player] = nil
				return
			end

			player:SetAttribute("IsInAutoHatching", true)
			self:TryOpenEgg(player, eggId, isTriple, isAuto)
		end
	end)
end

function HatchEggService:TryOpenEgg(player, eggId, isTriple, IsAuto)
	if self._debounces[player] then return end

	self._debounces[player] = true

	local egg = EggConfig[eggId]

	if not egg then
		removePlayerFromDebounce(self, player)
		return
	end

	if isTriple and not player:GetAttribute("TripleHatch") then
		removePlayerFromDebounce(self, player)
		return
	end

	if not self._services.WorldsService:IsWorldUnlocked(player, egg.World) then
		removePlayerFromDebounce(self, player)
		return
	end

	local amount = isTriple and 3 or 1

	if egg.Currency ~= "Cash" then 
		removePlayerFromDebounce(self, player)
		return
	end

	if not self._services.PetService:CheckAvailableStorage(player, amount) then
		removePlayerFromDebounce(self, player)
		return
	end

	local price = egg.Price * amount

	if player.Currencies.Cash.Value < price then
		self._services.ServerMessagesSender:SendMessageToPlayer(player, "Error", "You can't afford to buy this!")
		removePlayerFromDebounce(self, player)
		return
	end

	local currencySpentSuccessfully = self._services.SoftCurrencyService:TrySpentCurrency(player, "Cash", price, "EggHatch", "EggHatch" .. eggId)

	if currencySpentSuccessfully then
		self:OpenEgg(player, eggId, isTriple, IsAuto)
		return true
	else
		removePlayerFromDebounce(self, player)
	end
end

function HatchEggService:Initialize()
	self._stopQueue = {}
	self._debounces = {}

	EggHatchRequested.OnServerEvent:Connect(function(player, eggId, isTriple, isAuto)
		self:TryOpenEgg(player, eggId, isTriple, isAuto)
	end)

	AutoStopRequested.OnServerEvent:Connect(function(player)
		self._stopQueue[player] = true
	end)

	-- ReplicatedStorage.Remotes.TestUnlockEgg.OnServerEvent:Connect(function(player)
	-- 	self:OpenEgg(player, "GlacierEgg", false, false)
	-- end)
end

function HatchEggService.new()
    local self = setmetatable(HatchEggService, {__index = ServiceTemplate})

	return self
end

return HatchEggService