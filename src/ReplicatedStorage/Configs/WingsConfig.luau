local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProductsConfig = require(script.Parent.DevProductsConfig)
local WingsConfig = {}

WingsConfig.Wings = {
    DemonWings = {
        PublicName = "Demon Wings";
        ConfigName = "DemonWings";
        Icon = "rbxassetid://92190724973951";
        JumpPowerMultiplier = 1.2;
        PriceInCash = 100;
        Model = ReplicatedStorage.Assets.Wings.DemonWings
    };
    WaterWings = {
        PublicName = "Water Wings";
        ConfigName = "WaterWings";
        Icon = "rbxassetid://92190724973951";
        JumpPowerMultiplier = 1.5;
        PriceInCash = 200;
        Model = ReplicatedStorage.Assets.Wings.WaterWings
    };
    DragonWings = {
        PublicName = "Dragon Wings";
        ConfigName = "DragonWings";
        Icon = "rbxassetid://92190724973951";
        JumpPowerMultiplier = 2;
        ProductId = DevProductsConfig.Wings.DragonWings;
        PriceInCash = 1; --for ordering needs only
        Model = ReplicatedStorage.Assets.Wings.DragonWings
    };
}

return WingsConfig