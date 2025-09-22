local SharedTypes = {}

export type TemporaryBoostData = {
    ModifiedStats: {[string]: number};
    Duration: number;
}

export type BoostsSave = {
    TemporaryBoosts: {
        [string]: TemporaryBoostData;
    };
    PermanentBoosts: {
        [string]: boolean | number;
    };
}

export type InventorySave = {
    Equipment: {
        Sacks: {[string]: boolean};
    };
}

export type WorldsSave = {
    CurrentWorld: number;
    UnlockedWorlds: {[number]: boolean}
}

return SharedTypes