local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TrailsConfig = require(ReplicatedStorage.Configs.TrailsConfig)

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local Players = game:GetService("Players")

local TrailsService = {}

local function createAttachment(character: Model, offset: Vector3, partName: string) : Attachment
	local part = Instance.new("Part")
	part.Position = character.HumanoidRootPart.Position + offset
	part.Anchored = false
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(1,1,1)
	part.Parent = character
	part.Name = partName

	local weld = Instance.new("WeldConstraint")
	weld.Parent = character.HumanoidRootPart
	weld.Part0 = character.HumanoidRootPart
	weld.Part1 = part

	local attachment = Instance.new("Attachment")
	attachment.Parent = part

	return attachment
end

local function initializeTrail(player: Player)
	local character = player.Character or player.CharacterAdded:Wait()
	createAttachment(character, Vector3.new(0, 1, 0), "attachment0")
	createAttachment(character, Vector3.new(0, -1, 0), "attachment1")
end

local function onPlayerAdded(self, player: Player)
	initializeTrail(player)

	self._connections[player] = player.CharacterAdded:Connect(function(_)
		initializeTrail(player)
	end)
end

local function onPlayerRemoving(self, player: Player)
	if self._connections[player] then
		self._connections[player]:Disconnect()
		self._connections[player] = nil
	end
end

function TrailsService:TryUnlockTrail(player: Player, trailName: string)
	if not TrailsConfig[trailName] then
		return warn("Trail with name " .. trailName .. " is not in config!")
	end

	if self._services.InventoryService:HasItem(player, "Equipment", "Trails", trailName) then return end

	if self._services.SoftCurrencyService:TrySpentCurrency(player, "Cash", TrailsConfig[trailName].Cost, Enum.AnalyticsEconomyTransactionType.Gameplay, "TrailPurchase") then
		self._services.InventoryService:TryAddItem(player, "Equipment", "Trails", trailName)
	end
end

function TrailsService:Initialize()
    for _, player in pairs(Players:GetChildren()) do
		onPlayerAdded(self, player)
	end

	Players.PlayerAdded:Connect(function(player: Player)
		onPlayerAdded(self, player)
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		onPlayerRemoving(self, player)
	end)
end

function TrailsService.new()
	local self = setmetatable(TrailsService, {__index = ServiceTemplate})
	self._connections = {}

	return self
end

return TrailsService