local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AchievementsConfig = require(ReplicatedStorage.Configs.AchievementsConfig)
local Remotes = ReplicatedStorage.Remotes.Achievements
local AchievementRewardGranted = Remotes.AchievementRewardGranted :: RemoteEvent
local GetAchievementsSave = Remotes.GetAchievementsSave :: RemoteFunction
local WorldUnlocked = ReplicatedStorage.Remotes.Worlds.WorldUnlocked :: RemoteEvent

local ControllerTemplate = require(ReplicatedStorage.Modules.ControllerTemplate)

local AchievementsController = {}

local achievementCheckerFunctions = {}

achievementCheckerFunctions["Food"] = function(self)
    return self._food.Value
end

achievementCheckerFunctions["Playtime"] = function(self)
    return self._totalPlaytime.Value
end

achievementCheckerFunctions["Eggs"] = function(self)
    return self._hatches.Value
end

achievementCheckerFunctions["Cash"] = function(self)
    return self._cash.Value
end

achievementCheckerFunctions["Inventory"] = function(self, categoryName)
    return self._inventoryCounts[categoryName]
end

achievementCheckerFunctions["Worlds"] = function(self)
    return self._highestOpenWorld
end

local function getCurrentValue(self, achievementType: string)
    local currentValue = 0

    if achievementType == "Sacks" or achievementType == "Wings" or achievementType == "Trails" then
        currentValue = achievementCheckerFunctions["Inventory"](self, achievementType)
    else
        currentValue = achievementCheckerFunctions[achievementType](self)
    end

    return currentValue
end

local function updateAchievementsOfType(self, achievementType: string)
    for index, achievement in AchievementsConfig do
        if achievement.GoalType ~= achievementType then continue end
        if self._currentState[index].IsClaimed then continue end

        local value = getCurrentValue(self, achievement.GoalType)

        self._currentState[index].IsCompleted = value >= achievement.Goal
        self._currentState[index].CurrentValue = value
        self.AchievementInfoUpdated:Invoke(index, self._currentState[index])
    end
end

local function initialize(self)
    for category, _ in self._inventoryCounts do
        self._inventoryCounts[category] = #self._inventory.Equipment[category] or 0
    end

    self._highestOpenWorld = 1

    for i = #self._configs.WorldsConfig.Worlds, 1, -1 do
        local unlocked = self._controllers.WorldsController:IsWorldUnlocked(i)

        if unlocked then
            self._highestOpenWorld = i
            break
        end
    end

    local save = GetAchievementsSave:InvokeServer()

    for index, achievement in AchievementsConfig do
        self._currentState[index] = {}

        if table.find(save, index) then
            self._currentState[index].IsClaimed = true
            self.AchievementInfoUpdated:Invoke(index, self._currentState[index])
            continue
        end

        local value = getCurrentValue(self, achievement.GoalType)

        self._currentState[index].IsCompleted = value >= achievement.Goal
        self._currentState[index].CurrentValue = value
        self.AchievementInfoUpdated:Invoke(index, self._currentState[index])
    end

    self._food.Changed:Connect(function()
        updateAchievementsOfType(self, "Food")
    end)

    self._hatches.Changed:Connect(function()
        updateAchievementsOfType(self, "Eggs")
    end)

    self._cash.Changed:Connect(function()
        updateAchievementsOfType(self, "Cash")
    end)

    self._totalPlaytime.Changed:Connect(function()
        updateAchievementsOfType(self, "Playtime")
    end)

    self._controllers.InventoryController.Updated:Subscribe(self, function(categoryType, categoryName)
        if categoryType == "Consumables" then return end

        self._inventoryCounts[categoryName] += 1
        updateAchievementsOfType(self, categoryName)
    end)

    WorldUnlocked.OnClientEvent:Connect(function(worldIndex)
        self._highestOpenWorld = worldIndex
        updateAchievementsOfType(self, "Worlds")
    end)

    AchievementRewardGranted.OnClientEvent:Connect(function(index: number)
        self._currentState[index].IsClaimed = true
        self.AchievementInfoUpdated:Invoke(index, self._currentState[index])
    end)
end

function AchievementsController:AfterPlayerLoaded(player: Player)
    self._player = player
    self._currentState = {}

    local totalStats = player:WaitForChild("TotalStats")
    self._food = totalStats:WaitForChild("TotalFood")
    self._totalPlaytime = totalStats:WaitForChild("TotalPlaytime")
    self._hatches = totalStats:WaitForChild("Hatches")
    self._cash = totalStats:WaitForChild("TotalCash")
    self._inventoryCounts = {
        Sacks = 0;
        Wings = 0;
        Trails = 0;
    }

    self._inventory = self._controllers.InventoryController:GetInventory()

    if not self._inventory then
        self._controllers.InventoryController.Initialized:Subscribe(self, function(inventory)
            self._inventory = inventory
            initialize(self)
            self._controllers.InventoryController.Initialized:Unsubscribe(self)
        end)
    else
        initialize(self)
    end
end

function AchievementsController:InjectUtils(utils)
    self.AchievementInfoUpdated = utils.Event.new()
    self._utils = utils
end

function AchievementsController.new()
    return setmetatable(AchievementsController, {__index = ControllerTemplate})
end

return AchievementsController