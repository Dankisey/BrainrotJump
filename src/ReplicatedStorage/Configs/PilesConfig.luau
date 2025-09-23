local PilesConfig = {}

PilesConfig.ViewStages = 3
PilesConfig.CollectingOffset = 3
PilesConfig.DefaultRegenerationTime = 10 --fallback if smth went wrong
PilesConfig.ArcsPerCollection = 4
PilesConfig.ArcsSpawningDelay = .2

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
        Chance = .45;
        MaxCapacity = 50;
        RegenerationTime = 5;
		Icon = "rbxassetid://73594619985915";
        TrailColor = ColorSequence.new(Color3.fromRGB(255, 241, 216));
    };
    Apple = {
        Chance = .35;
        MaxCapacity = 75;
        RegenerationTime = 10;
		Icon = "rbxassetid://108483940237372";
        TrailColor = ColorSequence.new(Color3.fromRGB(255, 178, 0));
	};
	Fruit = {
		Chance = .15;
		MaxCapacity = 85;
		RegenerationTime = 10;
		Icon = "rbxassetid://138796213301361";
        TrailColor = ColorSequence.new(Color3.fromRGB(255, 183, 252));
	};
	JarOfBerries = {
		Chance = .05;
		MaxCapacity = 100;
		RegenerationTime = 15;
		Icon = "rbxassetid://70684150833839";
        TrailColor = ColorSequence.new(Color3.fromRGB(68, 88, 254));
	};
}

return PilesConfig