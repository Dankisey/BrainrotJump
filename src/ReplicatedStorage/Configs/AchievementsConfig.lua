local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FormatNumber = require(ReplicatedStorage.Modules.Utils.FormatNumber)

local AchievementsConfig = {
	-------------------------Cash-------------------------
    [1] = {
        GoalText = "Collect " .. FormatNumber(10000) .. " Cash";
        LayoutOrder = 1;
        GoalType = "Cash";
        Goal = 10000;

        RewardScreenName = "Wins";
        RewardShowAmount = 100;
        RewardIcon = "rbxassetid://74036095975091";

        RewardData = {
            Name = "Wins";
			Data = 100;
        };
    };
	[2] = {
		GoalText = "Collect " .. FormatNumber(1000000) .. " Cash";
		LayoutOrder = 1;
		GoalType = "Cash";
		Goal = 1000000;

		RewardScreenName = "Wins";
		RewardShowAmount = 1000;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 1000;
		};
	};
	[3] = {
		GoalText = "Collect " .. FormatNumber(100000000) .. " Cash";
		LayoutOrder = 1;
		GoalType = "Cash";
		Goal = 100000000;

		RewardScreenName = "Cash Potion";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://81695272763293";

		RewardData = {
			Name = "Potions";
			Data = {CashPotion = 1;}
		};
	};
	[4] = {
		GoalText = "Collect " .. FormatNumber(10000000000) .. " Cash";
		LayoutOrder = 1;
		GoalType = "Cash";
		Goal = 10000000000;

		RewardScreenName = "Wins";
		RewardShowAmount = 10000;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 10000;
		};
	};
    [5] = {
		GoalText = "Collect " .. FormatNumber(100000000000) .. " Cash";
        LayoutOrder = 1;
        GoalType = "Cash";
		Goal = 100000000000;

        RewardScreenName = "OP Pet";
        RewardShowAmount = 1;
		RewardIcon = "rbxassetid://96933618401365";

        RewardData = {
			Name = "Pet";
			Data = "Dolfen";
		};
    };
	-------------------------Eggs-------------------------
    [7] = {
        GoalText = "Hatch 50 eggs";
        LayoutOrder = 3;
        GoalType = "Eggs";
        Goal = 50;

		RewardScreenName = "Wins";
		RewardShowAmount = 100;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 100;
		};
    };
	[8] = {
		GoalText = "Hatch 250 eggs";
		LayoutOrder = 3;
		GoalType = "Eggs";
		Goal = 250;

		RewardScreenName = "Wins";
		RewardShowAmount = 1000;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 1000;
		};
	};
	[9] = {
		GoalText = "Hatch 1000 eggs";
		LayoutOrder = 3;
		GoalType = "Eggs";
		Goal = 1000;

		RewardScreenName = "Wins Potion";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://127336974006859";

		RewardData = {
			Name = "Potions";
			Data = {WinsPotion = 1;}
		};
	};
	[10] = {
		GoalText = "Hatch 5000 eggs";
		LayoutOrder = 3;
		GoalType = "Eggs";
		Goal = 5000;

		RewardScreenName = "Wins";
		RewardShowAmount = 100000;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 100000;
		};
	};
	[11] = {
		GoalText = "Hatch 10000 eggs";
		LayoutOrder = 3;
		GoalType = "Eggs";
		Goal = 10000;

		RewardScreenName = "OP Pet";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://96933618401365";

		RewardData = {
			Name = "Pet";
			Data = "Dolfen";
		};
	};
	-------------------------Food-------------------------
    [13] = {
        GoalText = "Collect 1000 food";
        LayoutOrder = 5;
        GoalType = "Food";
        Goal = 1000;

        RewardScreenName = "Cash";
        RewardShowAmount = 250000;
        RewardIcon = "rbxassetid://80513201967002";

        RewardData = {
            Name = "Cash";
            Data = {
                Amount = 250000;
                TransactionType = Enum.AnalyticsEconomyTransactionType.Gameplay;
                Sku = "Achievement"
            };
        };
    };
	[14] = {
		GoalText = "Collect 5000 food";
		LayoutOrder = 5;
		GoalType = "Food";
		Goal = 5000;

		RewardScreenName = "Cash";
		RewardShowAmount = 500000;
		RewardIcon = "rbxassetid://80513201967002";

		RewardData = {
			Name = "Cash";
			Data = {
				Amount = 500000;
				TransactionType = Enum.AnalyticsEconomyTransactionType.Gameplay;
				Sku = "Achievement"
			};
		};
	};
	[15] = {
		GoalText = "Collect 10000 food";
		LayoutOrder = 5;
		GoalType = "Food";
		Goal = 10000;

		RewardScreenName = "Cash Potion";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://81695272763293";

		RewardData = {
			Name = "Potions";
			Data = {CashPotion = 1;}
		};
	};
	[16] = {
		GoalText = "Collect 25000 food";
		LayoutOrder = 5;
		GoalType = "Food";
		Goal = 25000;

		RewardScreenName = "Cash";
		RewardShowAmount = 5000000;
		RewardIcon = "rbxassetid://80513201967002";

		RewardData = {
			Name = "Cash";
			Data = {
				Amount = 5000000;
				TransactionType = Enum.AnalyticsEconomyTransactionType.Gameplay;
				Sku = "Achievement"
			};
		};
	};
	[17] = {
		GoalText = "Collect 100000 food";
		LayoutOrder = 5;
		GoalType = "Food";
		Goal = 100000;

		RewardScreenName = "OP Pet";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://96933618401365";

		RewardData = {
			Name = "Pet";
			Data = "Turtle";
		};
	};
	-------------------------Worlds-------------------------
    [19] = {
        GoalText = "Discover 2 worlds";
        LayoutOrder = 7;
        GoalType = "Worlds";
        Goal = 2;

		RewardScreenName = "Wins";
		RewardShowAmount = 50000;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 50000;
		};
    };
	[20] = {
		GoalText = "Discover 3 worlds";
		LayoutOrder = 7;
		GoalType = "Worlds";
		Goal = 3;

		RewardScreenName = "Wins";
		RewardShowAmount = 1000;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 1000;
		};
	};
	[21] = {
		GoalText = "Discover 4 worlds";
		LayoutOrder = 7;
		GoalType = "Worlds";
		Goal = 4;

		RewardScreenName = "Wins";
		RewardShowAmount = 10000;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 10000;
		};
	};
	[22] = {
		GoalText = "Discover 5 worlds";
		LayoutOrder = 7;
		GoalType = "Worlds";
		Goal = 5;

		RewardScreenName = "Wins";
		RewardShowAmount = 100000;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 100000;
		};
	};
	-------------------------Sacks-------------------------
    [24] = {
        GoalText = "Collect 5 Sacks";
        LayoutOrder = 9;
        GoalType = "Sacks";
        Goal = 5;

        RewardScreenName = "Cash";
        RewardShowAmount = 10000;
        RewardIcon = "rbxassetid://80513201967002";

        RewardData = {
            Name = "Cash";
            Data = {
                Amount = 10000;
                TransactionType = Enum.AnalyticsEconomyTransactionType.Gameplay;
                Sku = "Achievement"
            };
        };
	};
	[25] = {
		GoalText = "Collect 10 Sacks";
		LayoutOrder = 9;
		GoalType = "Sacks";
		Goal = 10;

		RewardScreenName = "Cash";
		RewardShowAmount = 500000;
		RewardIcon = "rbxassetid://80513201967002";

		RewardData = {
			Name = "Cash";
			Data = {
				Amount = 500000;
				TransactionType = Enum.AnalyticsEconomyTransactionType.Gameplay;
				Sku = "Achievement"
			};
		};
	};
	[26] = {
		GoalText = "Collect 15 Sacks";
		LayoutOrder = 9;
		GoalType = "Sacks";
		Goal = 15;

		RewardScreenName = "Jump Power Potion";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://118990896434580";

		RewardData = {
			Name = "Potions";
			Data = {JumpPowerPotion = 1;}
		};
	};
	[27] = {
		GoalText = "Collect 20 Sacks";
		LayoutOrder = 9;
		GoalType = "Sacks";
		Goal = 20;

		RewardScreenName = "Cash";
		RewardShowAmount = 50000000;
		RewardIcon = "rbxassetid://80513201967002";

		RewardData = {
			Name = "Cash";
			Data = {
				Amount = 50000000;
				TransactionType = Enum.AnalyticsEconomyTransactionType.Gameplay;
				Sku = "Achievement"
			};
		};
	};
	[28] = {
		GoalText = "Collect 25 Sacks";
		LayoutOrder = 9;
		GoalType = "Sacks";
		Goal = 25;

		RewardScreenName = "OP Pet";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://96933618401365";

		RewardData = {
			Name = "Pet";
			Data = "Dolfen";
		};
	};
	-------------------------Wings-------------------------
    [30] = {
        GoalText = "Collect 9 Wings";
        LayoutOrder = 11;
        GoalType = "Wings";
        Goal = 9;

        RewardScreenName = "Cash";
        RewardShowAmount = 10000;
        RewardIcon = "rbxassetid://80513201967002";

        RewardData = {
            Name = "Cash";
            Data = {
                Amount = 10000;
                TransactionType = Enum.AnalyticsEconomyTransactionType.Gameplay;
                Sku = "Achievement"
            };
        };
	};
	[31] = {
		GoalText = "Collect 18 Wings";
		LayoutOrder = 11;
		GoalType = "Wings";
		Goal = 18;

		RewardScreenName = "Cash";
		RewardShowAmount = 500000;
		RewardIcon = "rbxassetid://80513201967002";

		RewardData = {
			Name = "Cash";
			Data = {
				Amount = 500000;
				TransactionType = Enum.AnalyticsEconomyTransactionType.Gameplay;
				Sku = "Achievement"
			};
		};
	};
	[32] = {
		GoalText = "Collect 27 Wings";
		LayoutOrder = 11;
		GoalType = "Wings";
		Goal = 27;

		RewardScreenName = "Jump Power Potion";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://118990896434580";

		RewardData = {
			Name = "Potions";
			Data = {JumpPowerPotion = 1;}
		};
	};
	[33] = {
		GoalText = "Collect 36 Wings";
		LayoutOrder = 11;
		GoalType = "Wings";
		Goal = 36;

		RewardScreenName = "Cash";
		RewardShowAmount = 50000000;
		RewardIcon = "rbxassetid://80513201967002";

		RewardData = {
			Name = "Cash";
			Data = {
				Amount = 50000000;
				TransactionType = Enum.AnalyticsEconomyTransactionType.Gameplay;
				Sku = "Achievement"
			};
		};
	};
	[34] = {
		GoalText = "Collect 45 Wings";
		LayoutOrder = 11;
		GoalType = "Wings";
		Goal = 45;

		RewardScreenName = "OP Pet";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://96933618401365";

		RewardData = {
			Name = "Pet";
			Data = "CursedGolem";
		};
	};
	-------------------------Trails-------------------------
    [36] = {
        GoalText = "Collect 3 trails";
        LayoutOrder = 13;
        GoalType = "Trails";
        Goal = 3;

		RewardScreenName = "Wins";
		RewardShowAmount = 1000;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 1000;
		};
	};
	[37] = {
		GoalText = "Collect 6 trails";
		LayoutOrder = 13;
		GoalType = "Trails";
		Goal = 6;

		RewardScreenName = "Wins";
		RewardShowAmount = 10000;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 10000;
		};
	};
	[38] = {
		GoalText = "Collect 9 trails";
		LayoutOrder = 13;
		GoalType = "Trails";
		Goal = 9;

		RewardScreenName = "Wins Potion";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://127336974006859";

		RewardData = {
			Name = "Potions";
			Data = {WinsPotion = 1;}
		};
	};
	[39] = {
		GoalText = "Collect 12 trails";
		LayoutOrder = 13;
		GoalType = "Trails";
		Goal = 12;

		RewardScreenName = "Wins";
		RewardShowAmount = 100000;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 100000;
		};
	};
	[40] = {
		GoalText = "Collect 16 trails";
		LayoutOrder = 13;
		GoalType = "Trails";
		Goal = 16;

		RewardScreenName = "OP Pet";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://96933618401365";

		RewardData = {
			Name = "Pet";
			Data = "AnglerFish";
		};
	};
	-------------------------Playtime-------------------------
    [42] = {
        GoalText = "Play for 1 minute in total";
        LayoutOrder = 15;
		GoalType = "Playtime";
        Goal = 60;

		RewardScreenName = "Wins";
		RewardShowAmount = 1000;
		RewardIcon = "rbxassetid://74036095975091";

		RewardData = {
			Name = "Wins";
			Data = 1000;
		};
	};
	[43] = {
		GoalText = "Play for 4 hours in total";
		LayoutOrder = 15;
		GoalType = "Playtime";
		Goal = 4 * 60 * 60;

		RewardScreenName = "Cash Potion";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://81695272763293";

		RewardData = {
			Name = "Potions";
			Data = {CashPotion = 1;}
		};
	};
	[44] = {
		GoalText = "Play for 7 hours in total";
		LayoutOrder = 15;
		GoalType = "Playtime";
		Goal = 7 * 60 * 60;

		RewardScreenName = "Wins Potion";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://127336974006859";

		RewardData = {
			Name = "Potions";
			Data = {WinsPotion = 1;}
		};
	};
	[45] = {
		GoalText = "Play for 10 hours in total";
		LayoutOrder = 15;
		GoalType = "Playtime";
		Goal = 10 * 60 * 60;

		RewardScreenName = "Jump Power Potion";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://118990896434580";

		RewardData = {
			Name = "Potions";
			Data = {JumpPowerPotion = 1;}
		};
	};
	[46] = {
		GoalText = "Play for 15 hours in total";
		LayoutOrder = 15;
		GoalType = "Playtime";
		Goal = 15 * 60 * 60;

		RewardScreenName = "OP Pet";
		RewardShowAmount = 1;
		RewardIcon = "rbxassetid://96933618401365";

		RewardData = {
			Name = "Pet";
			Data = "Dolfen";
		};
	};
}

return AchievementsConfig