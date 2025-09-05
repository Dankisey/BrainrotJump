local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local ClientTypes = require(ReplicatedStorage.Modules.ClientTypes)
local WorldsConfig = require(ReplicatedStorage.Configs.WorldsConfig)

local WorldViewAssets = ReplicatedStorage.Assets.Worlds
local Remotes = ReplicatedStorage.Remotes.Worlds
local WorldUnlocked = Remotes.WorldUnlocked
local WorldChanged = Remotes.WorldChanged
local GetSave = Remotes.GetSave

local WorldsController = {} :: ClientTypes.WorldsController

local function connectWorldsRing(self: ClientTypes.WorldsController)
    local ringCollider: Part = workspace:WaitForChild("LobbyModels"):WaitForChild("Worlds"):WaitForChild("Collider")

    ringCollider.Touched:Connect(function(otherPart: BasePart)
        if otherPart.Name ~= "HumanoidRootPart" or otherPart.Parent ~= self._player.Character then return end

        if self._isPlayerInRing then return end

        self._isPlayerInRing = true
        self.GuiOpenZoneEntered:Invoke()
    end)

    ringCollider.TouchEnded:Connect(function(otherPart: BasePart)
        if otherPart.Name ~= "HumanoidRootPart" or otherPart.Parent ~= self._player.Character then return end

        if not self._isPlayerInRing then return end

        self._isPlayerInRing = false
    end)
end

local function onWorldChanged(self: ClientTypes.WorldsController)
    local worldIndex = self._worldIndex.Value
    local worldInfo = WorldsConfig.Worlds[worldIndex]

    self._controllers.CharacterMovementController:DisableMovement()
    local completed = self._controllers.GuiController.FadingGui:FadeIn()

    if completed then
        completed:Wait()
    end

    local newView = WorldViewAssets:WaitForChild(tostring(worldIndex)):Clone()
    self._currentViewFolder:Destroy()
    self._currentViewFolder = newView
    self._currentViewFolder.Parent = workspace.Visuals

    self._baseplateTexture.Color3 = worldInfo.BaseplateColor

    self.WorldChanged:Invoke()
    self._controllers.GuiController.FadingGui:FadeOut()
    self._controllers.CharacterMovementController:EnableMovement()
end

function WorldsController:RequestWorldChange(worldIndex: number)
    WorldChanged:FireServer(worldIndex)
end

function WorldsController:RequestWorldUnlock(worldIndex: number)
    WorldUnlocked:FireServer(worldIndex)
end

function WorldsController:IsWorldUnlocked(worldIndex: number): boolean
    if not self._save then return false end

    return self._save.UnlockedWorlds[worldIndex] ~= nil
end

function WorldsController:GetCurrentWorldIndex(): number
    while not self._worldIndex do
        task.wait()
    end

    return self._worldIndex.Value
end

function WorldsController:AfterPlayerLoaded(player: Player)
    self._baseplateTexture = workspace:WaitForChild("Baseplate"):WaitForChild("Texture")
    self._currentViewFolder = workspace:WaitForChild("Visuals"):WaitForChild("1")
    self._worldIndex = player:WaitForChild("CurrentWorld"):WaitForChild("Index")
    self._player = player

    self._worldIndex.Changed:Connect(function()
        onWorldChanged(self)
    end)

    onWorldChanged(self)

    self._save = GetSave:InvokeServer()
    self.Updated:Invoke()

    WorldUnlocked.OnClientEvent:Connect(function(worldIndex)
        self._save.UnlockedWorlds[worldIndex] = true
        self.Updated:Invoke()
    end)

    connectWorldsRing(self)
end

function WorldsController:InjectUtils(utils)
    self.GuiOpenZoneEntered = utils.Event.new()
    self.WorldChanged = utils.Event.new()
    self.Updated = utils.Event.new()
    self._utils = utils
end

function WorldsController.new()
    local self = setmetatable(WorldsController, {__index = ControllerTemplate})

    return self
end

return WorldsController