local UpgradesConfig = {}

UpgradesConfig.Upgrades = {
    BrainrotSize = {
        PublicName = "Brainrot Size";
		Icon = "rbxassetid://133188277389753";
        LevelObjectName = "BrainrotSizeLevel";

        Levels = {
            [1] = {
                Scale = 1;
                HeightMultiplier = 1;
            };
            [2] = {
                Scale = 2;
                HeightMultiplier = 1.2;
            };
            [3] = {
                Scale = 3;
                HeightMultiplier = 1.5;

                WorldLock = 2;
            };
        };
    };
    CashMultiplier = {
        PublicName = "Cash Multiplier";
		Icon = "rbxassetid://18885492705";
        LevelObjectName = "CashMultiplierLevel";

        Levels = {
            [1] = {
                Value = 1;
            };
            [2] = {
                Value = 1.5;
            };
            [3] = {
                Value = 2;
                WorldLock = 2;
            };
        };
    };
    FoodCollectingRadius = {
        PublicName = "Food Collecting Radius";
		Icon = "rbxassetid://140480601874521";
        LevelObjectName = "FoodCollectingRadiusLevel";

        Levels = {
            [1] = {
                Value = 10;
            };
            [2] = {
                Value = 30;
            };
            [3] = {
                Value = 40;
                WorldLock = 2;
            };
        };
    };
    FoodCollectingSpeed = {
        PublicName = "Food Collecting Speed";
		Icon = "rbxassetid://73583481620723";
        LevelObjectName = "FoodCollectingSpeedLevel";

        Levels = {
            [1] = {
                Value = 1;
            };
            [2] = {
                Value = 1.5;
            };
            [3] = {
                Value = 2;
                WorldLock = 2;
            };
        };
    };
    FoodMultiplier = {
        PublicName = "Food Multiplier";
		Icon = "rbxassetid://138352037251053";
        LevelObjectName = "FoodMultiplierLevel";

        Levels = {
            [1] = {
                Value = 1;
            };
            [2] = {
                Value = 3;
            };
            [3] = {
                Value = 5;
                WorldLock = 2;
            };
        };
    };
    CollectingPiles = {
        PublicName = "Food Sources";
		Icon = "rbxassetid://84692930918491";
        LevelObjectName = "CollectingPilesLevel";

        Levels = {
            [1] = {
                Value = 1;
            };
            [2] = {
                Value = 2;
            };
            [3] = {
                Value = 4;
                WorldLock = 2;
            };
        };
    };
    WinsMultiplier = {
        PublicName = "Wins Multiplier";
		Icon = "rbxassetid://74036095975091";
        LevelObjectName = "WinsMultiplierLevel";

        Levels = {
            [1] = {
                Value = 1;
            };
            [2] = {
                Value = 2;
            };
            [3] = {
                Value = 3;
                WorldLock = 2;
            };
        };
    };
}

UpgradesConfig.AttributeBasedUpgrades = {
    CollectingPiles = "CollectingPiles";
    FoodCollectingRadius = "CollectingRadius";
    FoodCollectingSpeed = "CollectingSpeedMultiplier";
}

return UpgradesConfig