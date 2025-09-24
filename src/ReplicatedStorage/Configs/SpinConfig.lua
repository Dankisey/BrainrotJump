local ConsumablesConfig = require(script.Parent.ConsumablesConfig)

local SpinConfig = {}

SpinConfig.FreeSpinRewardTime = 30 * 60
SpinConfig.FullSpinTime = .7
SpinConfig.RewardDelay = 1

SpinConfig.FullSpinsAmount = {
    Min = 3;
    Max = 5;
}

SpinConfig.Rewards = {
    [1] ={
        --//Rarest reward (rainbow label)
        Rewards = {
			Pet = "MythicChristmasRobot";
        };

        ShowingInfo = "OOP Pet";
		Icon = "rbxassetid://89846447033559";
        Chance = .01;

        TooltipInfo = {
            Type = "Pet";
			PetName = "MythicChristmasRobot";
            IsGold = false;
            IsShiny = false;
        };
    };
    [2] = {
        Rewards = {
            Potions = {
                JumpPowerPotion = 1;
            };
        };

        ShowingInfo = "Jump Power Potion";
        Icon = "rbxassetid://118990896434580";
        Chance = 0.08;

        TooltipInfo = ConsumablesConfig.UiInfo.JumpPowerPotion.TooltipInfo;
    };
    [3] = {
        Rewards = {
            Potions = {
                CashPotion = 1;
            };
        };

        ShowingInfo = "Cash Potion";
        Icon = "rbxassetid://81695272763293";
        Chance = 0.08;

        TooltipInfo = ConsumablesConfig.UiInfo.CashPotion.TooltipInfo;
    };
    [4] = {
        Rewards = {
            Cash = {
                Amount = 5_000;
                TransactionType = Enum.AnalyticsEconomyTransactionType.Gameplay.Name;
                Sku = "SpinWheelReward";
            };
        };

        ShowingInfo = "Cash x5k";
		Icon = "rbxassetid://18885492705";
        Chance = .3;

        TooltipInfo = {
            Type = "Default";
            Text = "Cash"
        };
    };
    [5] = {
        Rewards = {
            Wins = 5_000;
        };

        ShowingInfo = "Wins x5k";
        Icon = "rbxassetid://74036095975091";
        Chance = .32;

        TooltipInfo = {
            Type = "Default";
            Text = "Wins"
        };
    };
    [6] = {
        Rewards = {
            Cash = {
                Amount = 10000;
                TransactionType = Enum.AnalyticsEconomyTransactionType.Gameplay.Name;
                Sku = "SpinWheelReward";
            };
        };

        ShowingInfo = "Coins x10k";
		Icon = "rbxassetid://18885492705";
        Chance = .08;

        TooltipInfo = {
            Type = "Default";
            Text = "Cash"
        };
    };
    [7] = {
		Rewards = {
			Potions = {
				WinsPotion = 1;
			};
		};

		ShowingInfo = "Wins Potion";
		Icon = "rbxassetid://127336974006859";
		Chance = 0.08;

		TooltipInfo = ConsumablesConfig.UiInfo.WinsPotion.TooltipInfo;
    };
    [8] = {
		Rewards = {
			Pet = "Shark";
		};

		ShowingInfo = "OP Pet";
		Icon = "rbxassetid://112950596621365";
		Chance = .05;

		TooltipInfo = {
			Type = "Pet";
			PetName = "Shark";
			IsGold = false;
			IsShiny = false;
		};
    };
}

return SpinConfig