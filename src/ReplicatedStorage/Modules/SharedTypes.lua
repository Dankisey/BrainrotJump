local SharedTypes = {}

export type InventorySave = {
    Equipment: {
        Baskets: {[string]: boolean};
    };
}

return SharedTypes