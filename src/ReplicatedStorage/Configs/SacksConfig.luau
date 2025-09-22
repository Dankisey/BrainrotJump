local DevProductsConfig = require(script.Parent.DevProductsConfig)
local RaritiesConfig = require(script.Parent.RaritiesConfig)
local SacksConfig = {}

SacksConfig.Items = {
    BasicSack = {
		PublicName = "Basic Sack";
		ConfigName = "BasicSack";
		Icon = "rbxassetid://128755273209996";
        FoodCapacity = 100;
        PriceInCash = 0;
        Rarity = RaritiesConfig.Common
    };
	PatchSack = {
		PublicName = "Patch Sack";
		ConfigName = "PatchSack";
		Icon = "rbxassetid://75509859485414";
        FoodCapacity = 200;
        PriceInCash = 100;
		Rarity = RaritiesConfig.Common
	};
	TrustySack = {
		PublicName = "Trusty Sack";
		ConfigName = "TrustySack";
		Icon = "rbxassetid://104038977138766";
		FoodCapacity = 100;
		PriceInCash = 0;
		Rarity = RaritiesConfig.Uncommon
	};
	SturdySack = {
		PublicName = "Sturdy Sack";
		ConfigName = "SturdySack";
		Icon = "rbxassetid://91248217228314";
		FoodCapacity = 200;
		PriceInCash = 100;
		Rarity = RaritiesConfig.Uncommon
	};
	SpikedSack = {
		PublicName = "Spiked Sack";
		ConfigName = "SpikedSack";
		Icon = "rbxassetid://132219495282238";
		FoodCapacity = 100;
		PriceInCash = 0;
		Rarity = RaritiesConfig.Uncommon
	};
	StarsSack = {
		PublicName = "Stars Sack";
		ConfigName = "StarsSack";
		Icon = "rbxassetid://73180731841401";
		FoodCapacity = 200;
		PriceInCash = 100;
		Rarity = RaritiesConfig.Rare
	};
	RainforcedSack = {
		PublicName = "Rainforced Sack";
		ConfigName = "RainforcedSack";
		Icon = "rbxassetid://131406426658454";
		FoodCapacity = 100;
		PriceInCash = 0;
		Rarity = RaritiesConfig.Rare
	};
	RainbowSack = {
		PublicName = "Rainbow Sack";
		ConfigName = "RainbowSack";
		Icon = "rbxassetid://124167974056004";
		FoodCapacity = 200;
		PriceInCash = 100;
		Rarity = RaritiesConfig.Epic
	};
	TreeSack = {
		PublicName = "Tree Sack";
		ConfigName = "TreeSack";
		Icon = "rbxassetid://106191292956919";
		FoodCapacity = 100;
		PriceInCash = 0;
		Rarity = RaritiesConfig.Epic
	};
	DiamondSack = {
		PublicName = "Diamond Sack";
		ConfigName = "DiamondSack";
		Icon = "rbxassetid://114966477244189";
		FoodCapacity = 200;
		PriceInCash = 100;
		Rarity = RaritiesConfig.Legendary
	};
	RadiantSack = {
		PublicName = "Radiant Sack";
		ConfigName = "RadiantSack";
		Icon = "rbxassetid://103265895381131";
		FoodCapacity = 100;
		PriceInCash = 0;
		Rarity = RaritiesConfig.Legendary
	};
	EmberSack = {
		PublicName = "Ember Sack";
		ConfigName = "EmberSack";
		Icon = "rbxassetid://90711633460816";
		FoodCapacity = 200;
		PriceInCash = 100;
		Rarity = RaritiesConfig.Legendary
	};
	LavaSack = {
		PublicName = "Lava Sack";
		ConfigName = "LavaSack";
		Icon = "rbxassetid://123849970810623";
		FoodCapacity = 100;
		PriceInCash = 0;
		Rarity = RaritiesConfig.Divine
	};
	ArcaneSack = {
		PublicName = "Arcane Sack";
		ConfigName = "ArcaneSack";
		Icon = "rbxassetid://102672793060633";
		FoodCapacity = 200;
		PriceInCash = 100;
		Rarity = RaritiesConfig.Divine
	};
	EnderSack = {
		PublicName = "Ender Sack";
		ConfigName = "EnderSack";
		Icon = "rbxassetid://116494883060883";
        FoodCapacity = 500;
		ProductId = DevProductsConfig.Sacks.RobuxSack;
        PriceInCash = 9999999999; --for ordering needs only
        Rarity = RaritiesConfig.Divine
    };
}

return SacksConfig