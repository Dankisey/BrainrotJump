local PilesConfig = {}

PilesConfig.ViewStages = 3
PilesConfig.CollectingOffset = 3
PilesConfig.DefaultRegenerationTime = 10 --fallback if smth went wrong

PilesConfig.Piles = {
    Green = {
        Chance = .5;
        MaxCapacity = 50;
        RegenerationTime = 10;
        Icon = "rbxassetid://92190724973951";
    };
    Red = {
        Chance = .5;
        MaxCapacity = 75;
        RegenerationTime = 20;
        Icon = "rbxassetid://92190724973951";
    };
}

return PilesConfig