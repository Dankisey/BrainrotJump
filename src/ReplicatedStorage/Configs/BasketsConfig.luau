local DevProductsConfig = require(script.Parent.DevProductsConfig)
local RaritiesConfig = require(script.Parent.RaritiesConfig)
local BasketsConfig = {}

BasketsConfig.Items = {
    Default = {
        PublicName = "Default Basket";
        ConfigName = "Default";
        Icon = "rbxassetid://92190724973951";
        FoodCapacity = 100;
        PriceInCash = 0;
        Rarity = RaritiesConfig.Common
    };
    Basket2 = {
        PublicName = "Test Basket";
        ConfigName = "Basket2";
        Icon = "rbxassetid://92190724973951";
        FoodCapacity = 200;
        PriceInCash = 100;
        Rarity = RaritiesConfig.Uncommon
    };
    RobuxBasket = {
        PublicName = "Robux Basket";
        ConfigName = "RobuxBasket";
        Icon = "rbxassetid://92190724973951";
        FoodCapacity = 500;
        ProductId = DevProductsConfig.Baskets.RobuxBasket;
        PriceInCash = 9999999999; --for ordering needs only
        Rarity = RaritiesConfig.Divine
    };
}

return BasketsConfig