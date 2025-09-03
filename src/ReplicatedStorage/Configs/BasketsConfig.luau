local DevProductsConfig = require(script.Parent.DevProductsConfig)
local BasketsConfig = {}

BasketsConfig.Items = {
    Default = {
        PublicName = "Default Basket";
        ConfigName = "Default";
        Icon = "rbxassetid://92190724973951";
        FoodCapacity = 100;
        PriceInCash = 0;
    };
    Basket2 = {
        PublicName = "TestBasket Basket";
        ConfigName = "Basket2";
        Icon = "rbxassetid://92190724973951";
        FoodCapacity = 200;
        PriceInCash = 100;
    };
    RobuxBasket = {
        PublicName = "Robux Basket";
        ConfigName = "RobuxBasket";
        Icon = "rbxassetid://92190724973951";
        FoodCapacity = 500;
        ProductId = DevProductsConfig.Baskets.RobuxBasket;
        PriceInCash = 9999999999;
    };
}

return BasketsConfig