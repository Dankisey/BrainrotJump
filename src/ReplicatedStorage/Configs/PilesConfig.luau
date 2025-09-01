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
    Green = {
        Chance = .5;
        MaxCapacity = 50;
        RegenerationTime = 5;
        Icon = "rbxassetid://92190724973951";
    };
    Red = {
        Chance = .5;
        MaxCapacity = 75;
        RegenerationTime = 10;
        Icon = "rbxassetid://92190724973951";
    };
}

return PilesConfig