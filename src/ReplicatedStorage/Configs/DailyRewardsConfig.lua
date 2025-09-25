local ConsumablesConfig = require(script.Parent.ConsumablesConfig)

local DailyRewardsConfig = {}

DailyRewardsConfig.SecondsInOneDay = 86400

DailyRewardsConfig.Rewards = {
    {
        Rewards = {
            Cash = {
                Amount = 500;
                TransactionType = Enum.AnalyticsEconomyTransactionType.TimedReward.Name;
                Sku = "DailyReward";
            };
        };

        Icon = "rbxassetid://18885492705";
        ShowingInfo = "+500";

        TooltipInfo = {
            Type = "Default";
            Text = "Use it to open eggs and buy trails"
        };
    };
    {
        Rewards = {
            Pet = "MythicStuffedImp"
        };

        Icon = "rbxassetid://136256762502880";
        ShowingInfo = "(OP) Mythic Stuffed Imp";

        TooltipInfo = {
            Type = "Pet";
            PetName = "MythicStuffedImp";
            IsGold = false;
            IsShiny = false;
        };
    };
    {
        Rewards = {
            Wins = 10000;
        };

        Icon = "rbxassetid://74036095975091";
        ShowingInfo = "+10,000";

        TooltipInfo = {
            Type = "Default";
            Text = "Use wins to unlock new worlds"
        };
    };
    {
        Rewards = {
            Potions = {
                JumpPowerPotion = 1;
            }
        };

        Icon = "rbxassetid://118990896434580";
        ShowingInfo = "x2 Jump Power";

        TooltipInfo = ConsumablesConfig.UiInfo.JumpPowerPotion.TooltipInfo;
    };
    {
        Rewards = {
            Cash = {
                Amount = 50_000;
                TransactionType = Enum.AnalyticsEconomyTransactionType.TimedReward.Name;
                Sku = "DailyReward";
            };
        };

        Icon = "rbxassetid://18885492705";
        ShowingInfo = "+50,000";

        TooltipInfo = {
            Type = "Default";
            Text = "Use it to open eggs and buy trails"
        };
    };
    {
        Rewards = {
            Potions = {
                CashPotion = 1;
            }
        };

        Icon = "rbxassetid://81695272763293";
        ShowingInfo = "x2 Cash";

        TooltipInfo = ConsumablesConfig.UiInfo.CashPotion.TooltipInfo;
    };
    {
        Rewards = {
            Pet = "GuardianKnight"
        };

        Icon = "rbxassetid://109385800918552";
        ShowingInfo = "(OP) Guardian Knight";

        TooltipInfo = {
            Type = "Pet";
            PetName = "GuardianKnight";
            IsGold = false;
            IsShiny = false;
        };
    };
}

return DailyRewardsConfig