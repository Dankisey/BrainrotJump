local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local RunService = game:GetService("RunService")

local BrainrotController = {}

function BrainrotController:AfterPlayerLoaded(player: Player)
    self._player = player
end

function BrainrotController:Initialize()
    self._inDebounce = false

end

function BrainrotController:InjectUtils(utils)
    self._utils = utils
end

function BrainrotController.new()
    return setmetatable(BrainrotController, {__index = ControllerTemplate})
end

return BrainrotController