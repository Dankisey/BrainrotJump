local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AchievementsConfig = require(ReplicatedStorage.Configs.AchievementsConfig)
local Remotes = ReplicatedStorage.Remotes.Achievements
local AchievementRewardRequested = Remotes.AchievementRewardRequested :: RemoteEvent
local AchievementRewardGranted = Remotes.AchievementRewardGranted :: RemoteEvent
local GetAchievementsSave = Remotes.GetAchievementsSave :: RemoteFunction

local AchievementsService = {}
local ServiceTemplate = require(script.Parent.Parent.ServiceTemplate)

local function giveReward(self, player: Player, index: number)
    local config = AchievementsConfig[index]
    self._services.RewardService:GiveReward(player, {FunctionName = config.RewardData.Name, Data = config.RewardData.Data})
    table.insert(self._playersSaves[player], index)
    AchievementRewardGranted:FireClient(player, index)
end

function AchievementsService:TryGiveReward(player: Player, index: number)
    if table.find(self._playersSaves[player], index) then return end

    local config = AchievementsConfig[index]

    if config.GoalType == "Cash" then
        if player.TotalStats.TotalCash.Value >= config.Goal then
            giveReward(self, player, index)
        end
    elseif config.GoalType == "Eggs" then
        if player.TotalStats.Hatches.Value >= config.Goal then
            giveReward(self, player, index)
        end
    elseif config.GoalType == "Food" then
        if player:WaitForChild("TotalStats", 2).TotalFood.Value >= config.Goal then
            giveReward(self, player, index)
        end
    elseif config.GoalType == "Worlds" then
        local highestOpenWorld = 1

        for i = #self._configs.WorldsConfig.Worlds, 1, -1 do
            local unlocked = self._services.WorldsService:IsWorldUnlocked(player, i)

            if unlocked then
                highestOpenWorld = i
                break
            end
        end

        if highestOpenWorld >= config.Goal then
            giveReward(self, player, index)
        end
    elseif config.GoalType == "Sacks" or config.GoalType == "Wings" or config.GoalType == "Trails" then
        local itemCount = self._services.InventoryService:CountItems(player, "Equipment", config.GoalType)

        if itemCount >= config.Goal then
            giveReward(self, player, index)
        end
    elseif config.GoalType == "Playtime" then
        if player.TotalStats.TotalPlaytime.Value >= config.Goal then
            giveReward(self, player, index)
        end
    end
end

function AchievementsService:LoadSave(player: Player, save: table)
    if not save then
        save = {}
    end

    self._playersSaves[player] = save

    self._playersTimeCounters[player] = task.spawn(function()
        local totalPlaytime = player.TotalStats.TotalPlaytime

        while task.wait(60) do
            totalPlaytime.Value += 60
        end
    end)
end

function AchievementsService:UnloadSave(player: Player)
    local save = self._playersSaves[player]

    self._playersSaves[player] = nil

    if self._playersTimeCounters[player] then
        task.cancel(self._playersTimeCounters[player])
        self._playersTimeCounters[player] = nil
    end

    return save
end

function AchievementsService:Initialize()
    self._playersSaves = {}
    self._playersTimeCounters = {}

    AchievementRewardRequested.OnServerEvent:Connect(function(player: Player, index: number)
        self:TryGiveReward(player, index)
    end)

    GetAchievementsSave.OnServerInvoke = function(player)
        return self._playersSaves[player]
    end
end

function AchievementsService.new()
	local self = setmetatable(AchievementsService, {__index = ServiceTemplate})

    return self
end

return AchievementsService