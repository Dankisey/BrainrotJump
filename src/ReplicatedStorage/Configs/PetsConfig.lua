local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PetsFolder = ReplicatedStorage.Assets.Pets

local PetsConfig = {}

PetsConfig.ServiceData = {
    DefaultDistanceFromPlayer = 5;
    MaxDistanceFromPlayer = 40;
    LerpTime = 0.15;
    MaxEquippedPets = 3;
    MaxStorageSpace = 30;
}

PetsConfig.RarityColors = {
	['Common'] = Color3.fromRGB(226, 226, 226),
	['Uncommon'] = Color3.fromRGB(55, 248, 38),
	['Rare'] = Color3.fromRGB(85, 170, 255),
	['Legendary'] = Color3.fromRGB(255, 191, 0),
	['Mythical'] = Color3.fromRGB(170, 0, 255),
	['Divine'] = Color3.fromRGB(255, 0, 0),
}

PetsConfig.TextColors = {
    ['Normal'] = Color3.fromRGB(255, 255, 255),
    ['Gold'] = Color3.fromRGB(245, 225, 0),
    ['Shiny'] = Color3.fromRGB(244, 235, 144),
}

export type PetData = {
    ConfigName: string;
    IsEquipped: boolean;
    IsGold: boolean;
    IsShiny: boolean;
}

PetsConfig.Pets = {
	-- World 1 Egg 1
    Lion = {
        DropChance = 0.49;
        CashMultiplier = 2;
        WinsMultiplier = 1;
        PetsToCraftGold = 9;
        PetsToCraftShiny = 3;
        GoldStatsMultiplier =1.25;
        ShinyStatsMultiplier = 2;
        Rarity = "Common";
        Model = PetsFolder.Lion;
    };
    QueenBee = {
        DropChance = 0.35;
        CashMultiplier = 3;
        WinsMultiplier = 1;
        PetsToCraftGold = 9;
        PetsToCraftShiny = 3;
        GoldStatsMultiplier =1.25;
        ShinyStatsMultiplier = 2;
        Rarity = "Common";
        Model = PetsFolder.QueenBee;
    };
    Monkey = {
        DropChance = 0.1;
        CashMultiplier = 4;
        WinsMultiplier = 1.1;
        PetsToCraftGold = 7;
        PetsToCraftShiny = 3;
        GoldStatsMultiplier =1.25;
        ShinyStatsMultiplier = 2;
        Rarity = "Uncommon";
        Model = PetsFolder.Monkey;
	};
	Bunny = {
		DropChance = 0.05;
		CashMultiplier = 5;
		WinsMultiplier = 1.2;
		PetsToCraftGold = 5;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Rare";
		Model = PetsFolder.Bunny;
	};
	RoboCat = {
		DropChance = 0.01;
		CashMultiplier = 10;
		WinsMultiplier = 1.4;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Legendary";
		Model = PetsFolder.RoboCat;
	};
	
	-- World 1 Egg 2
	
	Tiger = {
		DropChance = 0.49;
		CashMultiplier = 5;
		WinsMultiplier = 1;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.Tiger;
	};
	Witch = {
		DropChance = 0.35;
		CashMultiplier = 10;
		WinsMultiplier = 1;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.Witch;
	};
	TechEye = {
		DropChance = 0.1;
		CashMultiplier = 15;
		WinsMultiplier = 1.1;
		PetsToCraftGold = 5;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Rare";
		Model = PetsFolder.TechEye;
	};
	Elephant = {
		DropChance = 0.05;
		CashMultiplier = 20;
		WinsMultiplier = 1.2;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Legendary";
		Model = PetsFolder.Elephant;
	};
	WolfSpider = {
		DropChance = 0.01;
		CashMultiplier = 50;
		WinsMultiplier = 1.4;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Mythical";
		Model = PetsFolder.WolfSpider;
	};
	
	-- World 2 Egg 1
	
	LightBat = {
		DropChance = 0.49;
		CashMultiplier = 15;
		WinsMultiplier = 1.1;
		PetsToCraftGold = 9;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Common";
		Model = PetsFolder.LightBat;
	};
	DemonTree = {
		DropChance = 0.35;
		CashMultiplier = 20;
		WinsMultiplier = 1.1;
		PetsToCraftGold = 9;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Common";
		Model = PetsFolder.DemonTree;
	};
	LavaBeast = {
		DropChance = 0.1;
		CashMultiplier = 25;
		WinsMultiplier = 1.2;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.LavaBeast;
	};
	AutumnSpirit = {
		DropChance = 0.05;
		CashMultiplier = 30;
		WinsMultiplier = 1.3;
		PetsToCraftGold = 5;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Rare";
		Model = PetsFolder.AutumnSpirit;
	};
	DemonicSpider = {
		DropChance = 0.01;
		CashMultiplier = 60;
		WinsMultiplier = 1.5;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Legendary";
		Model = PetsFolder.DemonicSpider;
	};
	
	-- World 2 Egg 2
	
	CreatureOfLight = {
		DropChance = 0.49;
		CashMultiplier = 30;
		WinsMultiplier = 1.1;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.CreatureOfLight;
	};
	DemonicDestroyer = {
		DropChance = 0.35;
		CashMultiplier = 40;
		WinsMultiplier = 1.1;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.DemonicDestroyer;
	};
	Radiance = {
		DropChance = 0.1;
		CashMultiplier = 50;
		WinsMultiplier = 1.2;
		PetsToCraftGold = 5;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Rare";
		Model = PetsFolder.Radiance;
	};
	LittleDemon = {
		DropChance = 0.05;
		CashMultiplier = 60;
		WinsMultiplier = 1.3;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Legendary";
		Model = PetsFolder.LittleDemon;
	};
	MythicStuffedImp = {
		DropChance = 0.01;
		CashMultiplier = 100;
		WinsMultiplier = 1.5;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Mythical";
		Model = PetsFolder.MythicStuffedImp;
	};
	
	-- World 3 Egg 1
	
	Gingerbread = {
		DropChance = 0.49;
		CashMultiplier = 50;
		WinsMultiplier = 1.2;
		PetsToCraftGold = 9;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Common";
		Model = PetsFolder.Gingerbread;
	};
	FestivePinguin = {
		DropChance = 0.35;
		CashMultiplier = 60;
		WinsMultiplier = 1.2;
		PetsToCraftGold = 9;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Common";
		Model = PetsFolder.FestivePinguin;
	};
	SantaGingerbread = {
		DropChance = 0.1;
		CashMultiplier = 70;
		WinsMultiplier = 1.4;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.SantaGingerbread;
	};
	SantaCat = {
		DropChance = 0.05;
		CashMultiplier = 80;
		WinsMultiplier = 1.6;
		PetsToCraftGold = 5;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Rare";
		Model = PetsFolder.SantaCat;
	};
	FestiveCat = {
		DropChance = 0.01;
		CashMultiplier = 150;
		WinsMultiplier = 2;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Legendary";
		Model = PetsFolder.FestiveCat;
	};
	
	-- World 3 Egg 2
	
	FestiveDragon = {
		DropChance = 0.49;
		CashMultiplier = 100;
		WinsMultiplier = 1.2;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.FestiveDragon;
	};
	FestivePanda = {
		DropChance = 0.35;
		CashMultiplier = 130;
		WinsMultiplier = 1.2;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.FestivePanda;
	};
	Rudolph = {
		DropChance = 0.1;
		CashMultiplier = 160;
		WinsMultiplier = 1.4;
		PetsToCraftGold = 5;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Rare";
		Model = PetsFolder.Rudolph;
	};
	GingerbreadMonkey = {
		DropChance = 0.05;
		CashMultiplier = 190;
		WinsMultiplier = 1.6;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Legendary";
		Model = PetsFolder.GingerbreadMonkey;
	};
	Gift = {
		DropChance = 0.01;
		CashMultiplier = 300;
		WinsMultiplier = 2;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Mythical";
		Model = PetsFolder.Gift;
	};
	
	-- World 4 Egg 1
	
	Angel = {
		DropChance = 0.49;
		CashMultiplier = 150;
		WinsMultiplier = 1.4;
		PetsToCraftGold = 9;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Common";
		Model = PetsFolder.Angel;
	};
	Angelfly = {
		DropChance = 0.35;
		CashMultiplier = 200;
		WinsMultiplier = 1.4;
		PetsToCraftGold = 9;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Common";
		Model = PetsFolder.Angelfly;
	};
	MythicLightPhoenix = {
		DropChance = 0.1;
		CashMultiplier = 250;
		WinsMultiplier = 1.7;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.MythicLightPhoenix;
	};
	Luminance = {
		DropChance = 0.05;
		CashMultiplier = 300;
		WinsMultiplier = 2;
		PetsToCraftGold = 5;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Rare";
		Model = PetsFolder.Luminance;
	};
	LittleCreature = {
		DropChance = 0.01;
		CashMultiplier = 500;
		WinsMultiplier = 2.5;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Legendary";
		Model = PetsFolder.LittleCreature;
	};
	
	-- World 4 Egg 2
	
	OrangeInfection = {
		DropChance = 0.49;
		CashMultiplier = 250;
		WinsMultiplier = 1.4;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.OrangeInfection;
	};
	Psychic = {
		DropChance = 0.35;
		CashMultiplier = 350;
		WinsMultiplier = 1.4;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.Psychic;
	};
	GuardianElemental = {
		DropChance = 0.1;
		CashMultiplier = 450;
		WinsMultiplier = 1.7;
		PetsToCraftGold = 5;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Rare";
		Model = PetsFolder.GuardianElemental;
	};
	PlasmaOverlord = {
		DropChance = 0.05;
		CashMultiplier = 550;
		WinsMultiplier = 2;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Legendary";
		Model = PetsFolder.PlasmaOverlord;
	};
	LightDemon = {
		DropChance = 0.01;
		CashMultiplier = 800;
		WinsMultiplier = 2.5;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Mythical";
		Model = PetsFolder.LightDemon;
	};
	
	-- World 5 Egg 1
	
	DiscusFish = {
		DropChance = 0.49;
		CashMultiplier = 300;
		WinsMultiplier = 1.6;
		PetsToCraftGold = 9;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Common";
		Model = PetsFolder.DiscusFish;
	};
	IceCube = {
		DropChance = 0.35;
		CashMultiplier = 400;
		WinsMultiplier = 1.6;
		PetsToCraftGold = 9;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Common";
		Model = PetsFolder.IceCube;
	};
	Shark = {
		DropChance = 0.1;
		CashMultiplier = 500;
		WinsMultiplier = 2;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.Shark;
	};
	IceDragon = {
		DropChance = 0.05;
		CashMultiplier = 600;
		WinsMultiplier = 2.4;
		PetsToCraftGold = 5;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Rare";
		Model = PetsFolder.IceDragon;
	};
	Cat = {
		DropChance = 0.01;
		CashMultiplier = 1000;
		WinsMultiplier = 3;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Legendary";
		Model = PetsFolder.Cat;
	};
	
	-- World 5 Egg 2
	
	LilakFish = {
		DropChance = 0.49;
		CashMultiplier = 650;
		WinsMultiplier = 1.6;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.LilakFish;
	};
	Turtle = {
		DropChance = 0.35;
		CashMultiplier = 900;
		WinsMultiplier = 1.6;
		PetsToCraftGold = 7;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Uncommon";
		Model = PetsFolder.Turtle;
	};
	AnglerFish = {
		DropChance = 0.1;
		CashMultiplier = 1150;
		WinsMultiplier = 2;
		PetsToCraftGold = 5;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Rare";
		Model = PetsFolder.AnglerFish;
	};
	CursedGolem = {
		DropChance = 0.05;
		CashMultiplier = 1400;
		WinsMultiplier = 2.4;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Legendary";
		Model = PetsFolder.CursedGolem;
	};
	Dolfen = {
		DropChance = 0.01;
		CashMultiplier = 2000;
		WinsMultiplier = 3;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Mythical";
		Model = PetsFolder.Dolfen;
	};
	
	-- Shiny Egg
	
	CandyPaladin = {
		DropChance = 0.8;
		CashMultiplier = 2000;
		WinsMultiplier = 6;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Mythical";
		Model = PetsFolder.CandyPaladin;
		Icon = "rbxassetid://129650622381258";
	};
	ReleaseOrb = {
		DropChance = 0.15;
		CashMultiplier = 5000;
		WinsMultiplier = 11;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Divine";
		Model = PetsFolder.ReleaseOrb;
		Icon = "rbxassetid://75468883484049";
	};
	MythicChristmasRobot = {
		DropChance = 0.05;
		CashMultiplier = 10000;
		WinsMultiplier = 20;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Divine";
		Model = PetsFolder.MythicChristmasRobot;
		Icon = "rbxassetid://89846447033559";
	};
	
	-- Sky Egg
	
	GuardianKnight = {
		DropChance = 0.8;
		CashMultiplier = 1000;
		WinsMultiplier = 3;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Mythical";
		Model = PetsFolder.GuardianKnight;
		Icon = "rbxassetid://109385800918552";
	};
	GingerbreadShard = {
		DropChance = 0.15;
		CashMultiplier = 3000;
		WinsMultiplier = 8;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Mythical";
		Model = PetsFolder.GingerbreadShard;
		Icon = "rbxassetid://115955596868544";
	};
	MythicCandyPaladin = {
		DropChance = 0.05;
		CashMultiplier = 6000;
		WinsMultiplier = 12;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Divine";
		Model = PetsFolder.MythicCandyPaladin;
		Icon = "rbxassetid://82888726270805";
	};
	
	-- Gold Egg
	
	FlameDrop = {
		DropChance = 0.8;
		CashMultiplier = 1500;
		WinsMultiplier = 4;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Mythical";
		Model = PetsFolder.FlameDrop;
		Icon = "rbxassetid://90746082715366";
	};
	Redemption = {
		DropChance = 0.15;
		CashMultiplier = 4000;
		WinsMultiplier = 9;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Divine";
		Model = PetsFolder.Redemption;
		Icon = "rbxassetid://111315821226451";
	};
	Electra = {
		DropChance = 0.05;
		CashMultiplier = 8000;
		WinsMultiplier = 14;
		PetsToCraftGold = 3;
		PetsToCraftShiny = 3;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Divine";
		Model = PetsFolder.Electra;
		Icon = "rbxassetid://73954449841849";
	};
	
	-- Exclusive pets
	
	DominusPolarius = {
		DropChance = 1;
		CashMultiplier = 500;
		WinsMultiplier = 5;
		PetsToCraftGold = 2;
		PetsToCraftShiny = 2;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Divine";
		Model = PetsFolder.DominusPolarius;
	};
	MythicGemShock = {
		DropChance = 1;
		CashMultiplier = 2500;
		WinsMultiplier = 10;
		PetsToCraftGold = 2;
		PetsToCraftShiny = 2;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Divine";
		Model = PetsFolder.MythicGemShock;
	};
	ShadowDominus = {
		DropChance = 1;
		CashMultiplier = 10000;
		WinsMultiplier = 15;
		PetsToCraftGold = 2;
		PetsToCraftShiny = 2;
		GoldStatsMultiplier =1.25;
		ShinyStatsMultiplier = 2;
		Rarity = "Divine";
		Model = PetsFolder.ShadowDominus;
	};
	
}

return PetsConfig