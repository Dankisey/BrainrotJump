local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EggConfig = require(ReplicatedStorage.Configs.EggConfig)
local ZonesFolder = workspace.PlayersZones
local EggsFolder = ReplicatedStorage.Assets.Eggs
local WingsGuiOpener = ReplicatedStorage.Assets.WingsGuiOpener

local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)
local ServerTypes = require(script.Parent.Parent.ServerTypes)
local ZonesService = {} :: ServerTypes.ZonesService

local function getTeleportPartByPlayer(player: Player): Part?
	local zoneId = player:GetAttribute("ZoneId")

	if not zoneId then return nil end

	local zone = ZonesFolder:FindFirstChild(tostring(zoneId)) :: Model

	if not zone then return nil end

	return zone:FindFirstChild("TeleportPart") :: Part
end

local function clearEggSpot(spot)
	if spot:FindFirstChildOfClass("Part") then
		spot:FindFirstChildOfClass("Part"):Destroy()
	end

	if spot:FindFirstChildOfClass("MeshPart") then
		spot:FindFirstChildOfClass("MeshPart"):Destroy()
	end
end

function ZonesService:GetPlayerZone(player: Player) : Model?
    return self._occupiedZones[player]
end

function ZonesService:AddEggs(player: Player, worldIndex: number?)
	local eggSpots = self._occupiedZones[player].EggSpots:GetChildren()
	local currentWorld = worldIndex or self._services.WorldsService:GetPlayerWorldIndex(player)
	local eggsToPlace = {}

	for eggName, eggInfo in EggConfig do
		if eggInfo.World ~= currentWorld then continue end

		table.insert(eggsToPlace, eggName)
	end

	for index, spot in eggSpots do
		clearEggSpot(spot)

		if not eggsToPlace[index] then continue end

		local egg = EggsFolder:FindFirstChild(eggsToPlace[index]):Clone()
		egg.Parent = spot
		egg:SetAttribute("Owner", player.UserId)
		egg:PivotTo(spot.CFrame + Vector3.new(0, 4, 0))
	end
end

function ZonesService:RemovePlayer(player: Player)
    local zone = self._occupiedZones[player]
	self._occupiedZones[player] = nil

    if not zone then return end

    local sign = zone.Sign
    sign:SetAttribute("PlayerName", "")
    sign:SetAttribute("ProfileImage", "")

    local signGui = sign.GuiHolder.Gui
    signGui.PlayerIcon.Visible = false
	signGui.PlayerTextLabel.Visible = false
	signGui.Likes.Visible = false
    signGui.EmptyTextLabel.Visible = true

	local wingsOpenerPoint = zone.WingsOpenerPoint
	wingsOpenerPoint:FindFirstChild("WingsGuiOpener"):Destroy()

	local eggSpots = zone.EggSpots:GetChildren()

	for _, spot in eggSpots do
		clearEggSpot(spot)
	end

	self.ZoneCleared:Invoke(player, zone)
	table.insert(self._emptyZones, zone)
end

function ZonesService:TeleportCharacterToAssignedZone(player: Player)
	local character = player.Character or player.CharacterAdded:Wait()
	local zoneId = player:GetAttribute("ZoneId")

	if not zoneId then
		player:GetAttributeChangedSignal("ZoneId"):Wait()
		zoneId = player:GetAttribute("ZoneId")
	end

	if not zoneId then return end

	local tpPart = getTeleportPartByPlayer(player)

	if not tpPart then return end

	character:PivotTo(tpPart.CFrame)
end

function ZonesService:RegisterPlayer(player: Player)
	if #self._emptyZones < 1 then
		return warn("An error occured while registering zone: no empty zones left, check the max players per server parameter")
	end

	local zone = table.remove(self._emptyZones)
	self._occupiedZones[player] = zone
	player:SetAttribute("ZoneId", zone.Name)

    local sign = zone.Sign
    sign:SetAttribute("PlayerName", player.Name)

    local profileImage = self._utils.GetPlayerProfileIcon(player.UserId)
    sign:SetAttribute("ProfileImage", profileImage)

    local signGui = sign.GuiHolder.Gui
    signGui.PlayerIcon.Visible = true
    signGui.PlayerIcon.Image = profileImage
    signGui.PlayerTextLabel.Visible = true
    signGui.PlayerTextLabel.Text = string.format("%s's Place", player.Name)
	signGui.EmptyTextLabel.Visible = false

	local wingsOpenerPoint = zone.WingsOpenerPoint
	local wingsGuiOpener = WingsGuiOpener:Clone()
	wingsGuiOpener.Parent = wingsOpenerPoint
	wingsGuiOpener:PivotTo(wingsOpenerPoint.CFrame)

	self.ZoneOccupied:Invoke(player, zone)

	task.delay(2, function()
		self:AddEggs(player)
	end)
end

function ZonesService:Initialize()
    for _, zone in pairs(ZonesFolder:GetChildren()) do
        table.insert(self._emptyZones, zone)
    end
end

function ZonesService:InjectUtils(utils)
	self.ZoneOccupied = utils.Event.new()
	self.ZoneCleared = utils.Event.new()
	self._utils = utils
end

function ZonesService.new()
    local self = setmetatable(ZonesService, {__index = ServiceTemplate})
    self._occupiedZones = {} :: {[Player]: Model}
    self._emptyZones = {} :: {Model}

    return self
end

return ZonesService