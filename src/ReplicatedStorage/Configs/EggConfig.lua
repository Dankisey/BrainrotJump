local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DevProductsConfig = require(ReplicatedStorage.Configs.DevProductsConfig)

local EggConfig = {
	
	-- Robux eggs
	
	SkyEgg = {
		Price = 299;
		Currency = 'Robux';
		PublicName = "Sky Egg";
		World = 1;
		Icon = "rbxassetid://76401521848701";
		ProductId = DevProductsConfig.Eggs.SkyEgg;
		ProductIdTriple = DevProductsConfig.TripleEggs.SkyEgg;
		Pets = {
			GuardianKnight = .8;
			GingerbreadShard = .15;
			MythicCandyPaladin = 0.05;
		}
	};
	GoldEgg = {
		Price = 499;
		Currency = 'Robux';
		PublicName = "Gold Egg";
		World = 1;
		Icon = "rbxassetid://120412992900520";
		ProductId = DevProductsConfig.Eggs.GoldEgg;
		ProductIdTriple = DevProductsConfig.TripleEggs.GoldEgg;
		Pets = {
			FlameDrop = .8;
			Redemption = .15;
			Electra = 0.05;

		};
	};
	ShinyEgg = {
		Price = 699;
		Currency = 'Robux';
		PublicName = "Shiny Egg";
		World = 1;
		Icon = "rbxassetid://102382023438597";
		ProductId = DevProductsConfig.Eggs.ShinyEgg;
		ProductIdTriple = DevProductsConfig.TripleEggs.ShinyEgg;
		Pets = {
			CandyPaladin = 0.8;
			ReleaseOrb = 0.15;
			MythicChristmasRobot = 0.05;
		};
	};
	
	-- World 1
	
	ButterflyEgg = {
		Price = 250;
		Currency = 'Cash';
		PublicName = "Butterfly Egg";
		World = 1;
		Icon = "rbxassetid://73867630621570";
		Pets = {
			Lion = .49;
			QueenBee = .35;
			Monkey = .1;
			Bunny = 0.05;
			RoboCat = 0.01;
		};
	};
	JungleEgg = {
		Price = 5000;
		Currency = 'Cash';
		PublicName = "Jungle Egg";
		World = 1;
		Icon = "rbxassetid://97155507954245";
		Pets = {
			Tiger = .49;
			Witch = .35;
			TechEye = .1;
			Elephant = 0.05;
			WolfSpider = 0.01;
		};
	};
	
	-- World 2
	
	LavaEgg = {
		Price = 50000;
		Currency = 'Cash';
		PublicName = "Lava Egg";
		World = 2;
		Icon = "rbxassetid://76127210892262";
		Pets = {
			LightBat = .49;
			DemonTree = .35;
			LavaBeast = .1;
			AutumnSpirit = 0.05;
			DemonicSpider = 0.01;
		};
	};
	FlameEgg = {
		Price = 500000;
		Currency = 'Cash';
		PublicName = "Flame Egg";
		World = 2;
		Icon = "rbxassetid://92511306202557";
		Pets = {
			CreatureOfLight = .49;
			DemonicDestroyer = .35;
			Radiance = .1;
			LittleDemon = 0.05;
			MythicStuffedImp = 0.01;
		};
	};
	
	-- World 3
	
	FrostEgg = {
		Price = 1500000;
		Currency = 'Cash';
		PublicName = "Frost Egg";
		World = 3;
		Icon = "rbxassetid://72688640729943";
		Pets = {
			Gingerbread = .49;
			FestivePinguin = .35;
			SantaGingerbread = .1;
			SantaCat = 0.05;
			FestiveCat = 0.01;
		};
	};
	GlacierEgg = {
		Price = 10000000;
		Currency = 'Cash';
		PublicName = "Glacier Egg";
		World = 3;
		Icon = "rbxassetid://72056799723271";
		Pets = {
			FestiveDragon = .49;
			FestivePanda = .35;
			Rudolph = .1;
			GingerbreadMonkey = 0.05;
			Gift = 0.01;
		};
	};
	
	-- World 4
	
	MoonEgg = {
		Price = 45000000;
		Currency = 'Cash';
		PublicName = "Moon Egg";
		World = 4;
		Icon = "rbxassetid://78266856668375";
		Pets = {
			Angel = .49;
			Angelfly = .35;
			MythicLightPhoenix = .1;
			Luminance = 0.05;
			LittleCreature = 0.01;
		};
	};
	SaturnEgg = {
		Price = 250000000;
		Currency = 'Cash';
		PublicName = "Saturn Egg";
		World = 4;
		Icon = "rbxassetid://93246335230931";
		Pets = {
			OrangeInfection = .49;
			Psychic = .35;
			GuardianElemental = .1;
			PlasmaOverlord = 0.05;
			LightDemon = 0.01;
		};
	};
	
	-- World 5
	
	DiamondEgg = {
		Price = 1500000000;
		Currency = 'Cash';
		PublicName = "Diamond Egg";
		World = 5;
		Icon = "rbxassetid://128017791198136";
		Pets = {
			DiscusFish = .49;
			IceCube = .35;
			Shark = .1;
			IceDragon = 0.05;
			Cat = 0.01;
		};
	};
	RainbowEgg = {
		Price = 10000000000;
		Currency = 'Cash';
		PublicName = "Rainbow Egg";
		World = 5;
		Icon = "rbxassetid://103524444449275";
		Pets = {
			LilakFish = .49;
			Turtle = .35;
			AnglerFish = .1;
			CursedGolem = 0.05;
			Dolfen = 0.01;
		};
	};
}

return EggConfig