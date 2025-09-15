local ConsumablesConfig = {}

ConsumablesConfig.Potions = {
    CashPotion = {
        BoostData = {
            ModifiedStats = {
                Cash = 2;
            };

            Duration = 15 * 60;
        };
    };
    JumpPowerPotion = {
        BoostData = {
            ModifiedStats = {
                JumpPower = 2;
            };

            Duration = 15 * 60;
        };
    };
    WinsPotion = {
        BoostData = {
            ModifiedStats = {
                Wins = 2;
            };

            Duration = 15 * 60;
        };
    };
}

ConsumablesConfig.UiInfo = {
    CashPotion = {
        LayoutOrder = 1;
        ItemType = "Potions";
        Name = "CashPotion";
        PublicName = "x2 Cash";
        Icon = "rbxassetid://81695272763293";
        TooltipInfo = {
            Type = "Default";
            Text = "<font color='#" .. Color3.fromRGB(25, 224, 15):ToHex() .. "'>+" ..
            math.round((ConsumablesConfig.Potions.CashPotion.BoostData.ModifiedStats.Cash - 1) * 100) .. "%</font> Cash";
        };
        WidgetOrder = 3;
    };
    JumpPowerPotion = {
        LayoutOrder = 2;
        ItemType = "Potions";
        Name = "JumpPowerPotion";
        PublicName = "x2 Jump Power";
        Icon = "rbxassetid://118990896434580";
        TooltipInfo = {
            Type = "Default";
            Text = "<font color='#" .. Color3.fromRGB(250, 41, 41):ToHex() .. "'>+" ..
            math.round((ConsumablesConfig.Potions.JumpPowerPotion.BoostData.ModifiedStats.JumpPower - 1) * 100) .. "%</font> Jump Power";
        };
        WidgetOrder = 3;
    };
    WinsPotion = {
        LayoutOrder = 3;
        ItemType = "Potions";
        Name = "WinsPotion";
        PublicName = "x2 Wins";
        Icon = "rbxassetid://127336974006859";
        TooltipInfo = {
            Type = "Default";
            Text = "<font color='#" .. Color3.fromRGB(41, 177, 250):ToHex() .. "'>+" ..
            math.round((ConsumablesConfig.Potions.WinsPotion.BoostData.ModifiedStats.Wins - 1) * 100) .. "%</font> Wins";
        };
        WidgetOrder = 3;
    };
}

return ConsumablesConfig