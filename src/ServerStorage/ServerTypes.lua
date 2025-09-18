local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedTypes = require(ReplicatedStorage.Modules.SharedTypes)
local UtilsTypes = require(ReplicatedStorage.Modules.UtilsTypes)

local Types = {}

export type Analytics = {
    new: () -> Analytics;

} & ServiceTemplate

export type BrainrotService = {
    LoadSave: (BrainrotService, player: Player, data: table) -> nil;
    UnloadSave: (BrainrotService, player: Player) -> table;
    GetPlayerBrainrot: (BrainrotService, player: Player) -> Model;

    _brainrots: {[Player]: {
        BrainrotLevel: number;
        BrainrotXP: number;
    }};
    _models: {[Player]: {
        Model: Model;
        AnimationTracks: table;
        AnimationsLoaded: boolean;
    }};
    _debounces: {[Player]: boolean};
} & ServiceTemplate

export type InventoryService = {
    TryAddItem: (InventoryService, player: Player, itemType: string, categoryName: string, itemName: string, amount: number?) -> boolean;
    HasItem: (InventoryService, player: Player, itemType: string, categoryName: string, itemName: string) -> boolean;
    ToggleWingsVisibility: (InventoryService, player: Player, enable: boolean) -> nil;
    RestoreEquippedItems: (InventoryService, player: Player) -> nil;
    RestoreEquippedWings: (InventoryService, player: Player) -> nil;

    LoadSave: (InventoryService, player: Player, savedInventory: SharedTypes.InventorySave?) -> nil;
    UnloadSave: (InventoryService, player: Player) -> SharedTypes.InventorySave;

    _equippedItemModels : {[Player]: {
        BasketPivot: Part?;
        Basket: Model?;
    }};
    _playersSaves : {[Player]: SharedTypes.InventorySave};
    _debounces : {[Players]: boolean};
} & ServiceTemplate

export type Monetization = {
    new: () -> Monetization;

    PromptProduct: (Monetization, player: Player, productId: number) -> nil;
    PromptPass: (Monetization, player: Player, passId: number) -> nil;
} & ServiceTemplate

export type RewardService = {
    new: () -> RewardService;

    GiveMultipleRewards: (RewardService, player: Player, rewards: {[string]: any}) -> nil;
    GiveReward: (RewardService, player: Player, rewardInfo: {FunctionName: string, Data: any}) -> nil;
} & ServiceTemplate

export type SavesLoader = {
    new: () -> SavesLoader;

    AddUsedCode: (SavesLoader, player: Player, code: string) -> nil;
    GetUsedCodes: (SavesLoader, player: Player) -> {string};
} & ServiceTemplate

export type ServerMessagesSender = {
    new: () -> ServerMessagesSender;

    SendMessageToPlayer: (ServerMessagesSender, player: Player, messageType: "Default"|"Congrats"|"Error", baseMessage: string, playerNames: {string}?) -> nil;
    SendMessage: (ServerMessagesSender, messageType: "Default"|"Congrats"|"Error", baseMessage: string, playerNames: {string}?) -> nil;
} & ServiceTemplate

export type SoftCurrencyService = {
    new: () -> SoftCurrencyService;

    TrySpentCurrency: (SoftCurrencyService, player: Player, currencyName: string, spentAmount: number, transactionType: Enum.AnalyticsEconomyTransactionType | string, itemSku: string?) -> boolean;
} & ServiceTemplate

export type UpgradesService = {
    new: () -> UpgradesService;

    TryGetBonus: (UpgradesService, player: Player, upgradeName: string) -> number?;
    TryGetLevel: (UpgradesService, player: Player, upgradeName: string) -> number?;

    _debounces: {[Player]: boolean}
} & ServiceTemplate

export type WorldsService = {
    new: () -> WorldsService;

    IsWorldUnlocked: (WorldsService, player: Player, worldIndex: number) -> boolean;
    GetPlayerWorldIndex: (WorldsService, player: Player) -> number?;

    LoadSave: (WorldsService, player: Player, savedInventory: SharedTypes.WorldsSave?) -> nil;
    UnloadSave: (WorldsService, player: Player) -> SharedTypes.WorldsSave;

    _playersSaves: {[Player]: SharedTypes.WorldsSave};
    _debounces : {[Players]: boolean};
} & ServiceTemplate

export type ZonesService = {
    new: () -> ZonesService;

    TeleportCharacterToAssignedZone: (ZonesService, player: Player) -> nil;
    GetPlayerZone: (ZonesService, player: Player) -> Model?;
    RegisterPlayer: (ZonesService, player: Player) -> nil;
    RemovePlayer: (ZonesService, player: Player) -> nil;

    ZoneOccupied: UtilsTypes.Event;
    ZoneCleared: UtilsTypes.Event;
} & ServiceTemplate

--[[========================================================================================]]

export type Services = {
    Analytics: Analytics;
    InventoryService: InventoryService;
    Monetization: Monetization;
    RewardService: RewardService;
    SavesLoader: SavesLoader;
    ServerMessagesSender: ServerMessagesSender;
    SoftCurrencyService: SoftCurrencyService;
    UpgradesService: UpgradesService;
    WorldsService: WorldsService;
    ZonesService: ZonesService;
}

--[[========================================================================================]]

export type ServiceTemplate = {
    InjectServices: (ServiceTemplate, services: Services) -> nil;
    InjectUtils: (ServiceTemplate, utils: UtilsTypes.Utils) -> nil;
    InjectConfigs: (ServiceTemplate, configs: {[string]: any}) -> nil;

    _services: Services;
    _utils: UtilsTypes.Utils;
    _configs: {[string]: any};
}

return Types