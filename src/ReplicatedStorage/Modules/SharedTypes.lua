local SharedTypes = {}

export type InventorySave = {
    Equipment: {
        Baskets: {[string]: boolean};
    };
}

export type WorldsSave = {
    CurrentWorld: number;
    UnlockedWorlds: {[number]: boolean}
}

return SharedTypes