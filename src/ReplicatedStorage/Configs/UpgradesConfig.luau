local UpgradesConfig = {}

UpgradesConfig.Upgrades = {
    BrainrotSize = {
        PublicName = "Brainrot Size";
        Icon = "rbxassetid://92190724973951";
        LevelObjectName = "BrainrotSizeLevel";

        Levels = {
            [1] = {
                Scale = 1;
                HeightMultiplier = 1;
            };
            [2] = {
                Scale = 1.1;
                HeightMultiplier = 1.2;
            };
            [3] = {
                Scale = 1.3;
                HeightMultiplier = 1.5;

                WorldLock = 2;
            };
        };
    };
    CashMultiplier = {
        PublicName = "Cash Multiplier";
        Icon = "rbxassetid://92190724973951";
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
        Icon = "rbxassetid://92190724973951";
        LevelObjectName = "FoodCollectingRadiusLevel";

        Levels = {
            [1] = {
                Value = 20;
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
        Icon = "rbxassetid://92190724973951";
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
        Icon = "rbxassetid://92190724973951";
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
        Icon = "rbxassetid://92190724973951";
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
        Icon = "rbxassetid://92190724973951";
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