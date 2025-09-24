local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProductsConfig = require(script.Parent.DevProductsConfig)
local WingsConfig = {}

WingsConfig.Wings = {
	AngelWings = {
		PublicName = "Angel Wings";
		ConfigName = "AngelWings";
		Icon = "rbxassetid://85750369209698";
		JumpPowerMultiplier = 1.2;
		PriceInCash = 100;
		Model = ReplicatedStorage.Assets.Wings.AngelWings
	};
	BatWings = {
		PublicName = "Bat Wings";
		ConfigName = "BatWings";
		Icon = "rbxassetid://115796049951380";
		JumpPowerMultiplier = 1.3;
		PriceInCash = 200;
		Model = ReplicatedStorage.Assets.Wings.BatWings
	};
	DragonWings = {
		PublicName = "Dragon Wings";
		ConfigName = "DragonWings";
		Icon = "rbxassetid://90763287600313";
		JumpPowerMultiplier = 1.4;
		PriceInCash = 300;
		Model = ReplicatedStorage.Assets.Wings.DragonWings
	};
	FallenWings = {
		PublicName = "Fallen Wings";
		ConfigName = "FallenWings";
		Icon = "rbxassetid://72014217052275";
		JumpPowerMultiplier = 1.5;
		PriceInCash = 400;
		Model = ReplicatedStorage.Assets.Wings.FallenWings
	};
	ArcWings = {
		PublicName = "Arc Wings";
		ConfigName = "ArcWings";
		Icon = "rbxassetid://133795823326626";
		JumpPowerMultiplier = 1.6;
		PriceInCash = 500;
		Model = ReplicatedStorage.Assets.Wings.ArcWings
	};
	WaterWings = {
		PublicName = "Water Wings";
		ConfigName = "WaterWings";
		Icon = "rbxassetid://137296590976796";
		JumpPowerMultiplier = 1.7;
		PriceInCash = 600;
		Model = ReplicatedStorage.Assets.Wings.WaterWings
	};
	EnderWings = {
		PublicName = "Ender Wings";
		ConfigName = "EnderWings";
		Icon = "rbxassetid://92114449131822";
		JumpPowerMultiplier = 1.8;
		PriceInCash = 700;
		Model = ReplicatedStorage.Assets.Wings.EnderWings
	};
	MutantWings = {
		PublicName = "Mutant Wings";
		ConfigName = "MutantWings";
		Icon = "rbxassetid://97361014199857";
        JumpPowerMultiplier = 1.9;
        PriceInCash = 800;
		Model = ReplicatedStorage.Assets.Wings.MutantWings
    };
    DemonWings = {
		PublicName = "Demon Wings";
		ConfigName = "DemonWings";
		Icon = "rbxassetid://97240308109831";
        JumpPowerMultiplier = 2;
        PriceInCash = 900;
		Model = ReplicatedStorage.Assets.Wings.DemonWings
    };
    Fairy = {
        PublicName = "Fairy Wings";
        ConfigName = "FairyWings";
		Icon = "rbxassetid://137394146351128";
        JumpPowerMultiplier = 3;
        ProductId = DevProductsConfig.Wings.FairyWings;
        PriceInCash = 1; --for ordering needs only
        Model = ReplicatedStorage.Assets.Wings.FairyWings
    };
}

return WingsConfig