local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PileView = require(script.PileView)

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)
local PilesReplicator = {} :: ControllerTemplate.Type

function PilesReplicator:AfterPlayerLoaded()
    local playerZone = self._controllers.ZoneController:GetZone()

    for _, spot: Part in pairs(CollectionService:GetTagged("PileSpot")) do
        if spot.Parent.Parent == playerZone then
            self._viewPerSpot[spot] = PileView.new(spot)
            table.insert(self._playerSpots, spot)
        else
            PileView.new(spot)
        end
    end
end

function PilesReplicator.new()
    local self = setmetatable(PilesReplicator, {__index = ControllerTemplate})
    self._viewPerSpot = {}
    self._playerSpots = {}

    return self
end

return PilesReplicator