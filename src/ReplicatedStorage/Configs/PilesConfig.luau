local PilesConfig = {}

PilesConfig.ViewStages = 3
PilesConfig.CollectingOffset = 3
PilesConfig.DefaultRegenerationTime = 10 --fallback if smth went wrong

PilesConfig.ArcData = {
    Duration = .5;
    Length = 10;
    Angles = {
        Min = -180;
        Max = 180;
    }
}

PilesConfig.Piles = {
    Bread = {
        Chance = .25;
        MaxCapacity = 50;
        RegenerationTime = 5;
		Icon = "rbxassetid://73594619985915";
    };
    Apple = {
        Chance = .25;
        MaxCapacity = 75;
        RegenerationTime = 10;
		Icon = "rbxassetid://108483940237372";
	};
	Fruit = {
		Chance = .25;
		MaxCapacity = 85;
		RegenerationTime = 10;
		Icon = "rbxassetid://138796213301361";
	};
	JarOfBerries = {
		Chance = .25;
		MaxCapacity = 100;
		RegenerationTime = 15;
		Icon = "rbxassetid://70684150833839";
	};
}

return PilesConfig