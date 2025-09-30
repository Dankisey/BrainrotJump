local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)
local Players = game:GetService("Players")

local Leaderstats = {}

local function onPlayerAdded(self, player: Player)
    local Cash = player:WaitForChild("Currencies"):WaitForChild("Cash")
    local HighestJump = player:WaitForChild("TotalStats"):WaitForChild("HighestJump")

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local leaderstatsCash = Instance.new("IntValue")
	leaderstatsCash.Name = "Current Cash"
	leaderstatsCash.Parent = leaderstats
	leaderstatsCash.Value = Cash.Value

    local leaderstatsJump = Instance.new("IntValue")
    leaderstatsJump.Name = "Highest Jump"
    leaderstatsJump.Parent = leaderstats
    leaderstatsJump.Value = HighestJump.Value

    self._connections[player] = {}

    table.insert(self._connections[player], Cash.Changed:Connect(function()
        leaderstatsCash.Value = Cash.Value
    end))

    table.insert(self._connections[player], HighestJump.Changed:Connect(function()
        leaderstatsJump.Value = HighestJump.Value
    end))
end

function Leaderstats:Initialize()
    for _, player: Player in Players:GetPlayers() do
        onPlayerAdded(self, player)
    end

    Players.PlayerAdded:Connect(function(player)
        onPlayerAdded(self, player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        if not self._connections[player] then return end

        for _, connection: RBXScriptConnection in pairs(self._connections[player]) do
            connection:Disconnect()
            connection = nil
        end

        self._connections[player] = nil
    end)
end

function Leaderstats.new()
    local self = setmetatable(Leaderstats, {__index = ServiceTemplate})
    self._connections = {}

    return self
end

return Leaderstats