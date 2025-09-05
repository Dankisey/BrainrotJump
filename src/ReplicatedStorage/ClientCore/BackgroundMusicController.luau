local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Music = SoundService:WaitForChild("Music")

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local BackgroundMusicController = {}

local function changeTrack(self, worldIndex: number)
    if self._currentWorldIndex == worldIndex then return end

    if self._currentMusic then
        self._currentMusic:Stop()
    end

    self._currentMusic = Music[worldIndex]
    self._currentWorldIndex = worldIndex
    self._currentMusic:Play()
end

function BackgroundMusicController:AfterPlayerLoaded(player: Player)
    changeTrack(self, self._controllers.WorldsController:GetCurrentWorldIndex())

    self._controllers.WorldsController.WorldChanged:Subscribe(self, function(worldIndex: number)
        changeTrack(self, worldIndex)
    end)
end

function BackgroundMusicController.new()
    return setmetatable(BackgroundMusicController, {__index = ControllerTemplate})
end

return BackgroundMusicController