local PermanentBoosts = {}

PermanentBoosts.Boosts = {
    Rebirth = {
        ModifiedStats = {
            Cash = 1.5;
        }
    };
    Premium = {
        ModifiedStats = {
            JumpPower = 1.5;
        }
    };
}

PermanentBoosts.UiInfo = {
    Rebirth = {
        Icon = "rbxassetid://80993270685237";
        TooltipInfo = {
            Type = "Default";
            Text = "<font color='#" .. Color3.fromRGB(41, 250, 48):ToHex() .. "'>+" ..
            math.round((PermanentBoosts.Boosts.Rebirth.ModifiedStats.Cash - 1) * 100) .. "%</font> Cash";
        };
        WidgetOrder = -1;
    };
    Premium = {
        Icon = "rbxasset://textures/ui/PlayerList/PremiumIcon@3x.png";
        TooltipInfo = {
            Type = "Default";
            Text = "<font color='#" .. Color3.fromRGB(250, 41, 41):ToHex() .. "'>+" ..
            math.round((PermanentBoosts.Boosts.Premium.ModifiedStats.JumpPower - 1) * 100) .. "%</font> Jump Power";
        };
        WidgetOrder = -2;
    };
}

return PermanentBoosts