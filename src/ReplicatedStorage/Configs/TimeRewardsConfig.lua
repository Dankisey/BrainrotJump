local DevProducts = require(script.Parent.DevProductsConfig)

local ConsumablesConfig = require(script.Parent.ConsumablesConfig)

local TimeRewardsConfig = {}

TimeRewardsConfig.SkipProductId = DevProducts.Others.SkipWaiting

TimeRewardsConfig.Rewards = {
    [1] = {
        Rewards = {
            Egg = "JungleEgg";
        };
        Icon = "rbxassetid://97155507954245";
        ShowingInfo = "Jungle Egg";
        Time = 60 * 1;

        TooltipInfo = {
            Type = "Default";
			Text = "Will open an egg with pets for you"
        }
    };
    [2] = {
		Rewards = {
			Cash = {
                Amount = 100;
                TransactionType = Enum.AnalyticsEconomyTransactionType.TimedReward.Name;
                Sku = "TimeReward";
            };
		};

		Icon = "rbxassetid://18885492705";
		ShowingInfo = "+100";
		Time = 60 * 2;

		TooltipInfo = {
			Type = "Default";
			Text = "Cash. Use it to open eggs and buy trails"
		};
    };
    [3] = {
        Rewards = {
            Wins = 1000;
        };
        Icon = "rbxassetid://74036095975091";
        ShowingInfo = "+1000";
        Time = 60 * 3;

        TooltipInfo = {
            Type = "Default";
			Text = "Wins. Use them to unlock new worlds"
        }
    };
    [4] = {
		Rewards = {
			Potions = {
				WinsPotion = 1;
			}
		};
		Icon = "rbxassetid://127336974006859";
		ShowingInfo = "x2 Wins";
		Time = 60 * 7;

		TooltipInfo = ConsumablesConfig.UiInfo.WinsPotion.TooltipInfo;
    };
    [5] = {
		Rewards = {
			Cash = {
                Amount = 500;
                TransactionType = Enum.AnalyticsEconomyTransactionType.TimedReward.Name;
                Sku = "TimeReward";
            };
		};

		Icon = "rbxassetid://18885492705";
		ShowingInfo = "+500";
		Time = 60 * 10;

		TooltipInfo = {
			Type = "Default";
			Text = "Cash. Use it to open eggs and buy trails"
		};
    };
    [6] = {
		Rewards = {
			Pet = "WolfSpider";
		};
		Icon = "rbxassetid://135261576090183";
		ShowingInfo = "WolfSpider";
		Time = 60 * 15;

		TooltipInfo = {
			Type = "Pet";
			PetName = "WolfSpider";
			IsGold = false;
			IsShiny = false;
		}
    };
    [7] = {
        Rewards = {
            Wins = 5000;
        };
        Icon = "rbxassetid://74036095975091";
        ShowingInfo = "+5000";
        Time = 60 * 20;

        TooltipInfo = {
            Type = "Default";
			Text = "Wins. Use them to unlock new worlds"
        }
    };
    [8] = {
		Rewards = {
			Cash = {
                Amount = 1500;
                TransactionType = Enum.AnalyticsEconomyTransactionType.TimedReward.Name;
                Sku = "TimeReward";
            };
		};

		Icon = "rbxassetid://18885492705";
		ShowingInfo = "+1500";
		Time = 60 * 25;

		TooltipInfo = {
			Type = "Default";
			Text = "Cash. Use it to open eggs and buy trails"
		};
    };
    [9] = {
		Rewards = {
			Potions = {
				JumpPowerPotion = 1;
			}
		};
		Icon = "rbxassetid://118990896434580";
		ShowingInfo = "x2 Jump Power";
		Time = 60 * 30;

		TooltipInfo = ConsumablesConfig.UiInfo.JumpPowerPotion.TooltipInfo;
    };
    [10] = {
        Rewards = {
            Wins = 25000;
        };
        Icon = "rbxassetid://74036095975091";
        ShowingInfo = "+25000";
        Time = 60 * 40;

        TooltipInfo = {
            Type = "Default";
			Text = "Wins. Use them to unlock new worlds"
        }
    };
    [11] = {
		Rewards = {
			Cash = {
                Amount = 7000;
                TransactionType = Enum.AnalyticsEconomyTransactionType.TimedReward.Name;
                Sku = "TimeReward";
            };
		};

		Icon = "rbxassetid://18885492705";
		ShowingInfo = "+7000";
		Time = 60 * 50;

		TooltipInfo = {
			Type = "Default";
			Text = "Cash. Use it to open eggs and buy trails"
		};
    };
    [12] = {
		Rewards = {
			Potions = {
				CashPotion = 1;
			}
		};
		Icon = "rbxassetid://81695272763293";
		ShowingInfo = "x2 Cash";
		Time = 60 * 60;

		TooltipInfo = ConsumablesConfig.UiInfo.CashPotion.TooltipInfo;
    };
    [13] = {
        Rewards = {
            Wins = 50000;
        };
        Icon = "rbxassetid://74036095975091";
        ShowingInfo = "+50000";
        Time = 60 * 70;

        TooltipInfo = {
            Type = "Default";
			Text = "Wins. Use them to unlock new worlds"
        }
    };
    [14] = {
		Rewards = {
			Potions = {
				WinsPotion = 2;
			}
		};
		Icon = "rbxassetid://127336974006859";
		ShowingInfo = "x2 Wins (2)";
		Time = 60 * 80;

		TooltipInfo = ConsumablesConfig.UiInfo.WinsPotion.TooltipInfo;
    };
    [15] = {
        Rewards = {
			Pet = "LightDemon";
        };
		Icon = "rbxassetid://99642471822157";
		ShowingInfo = "LightDemon";
        Time = 60 * 90;

        TooltipInfo = {
            Type = "Pet";
			PetName = "LightDemon";
            IsGold = false;
            IsShiny = false;
        }
    };
}

return TimeRewardsConfig