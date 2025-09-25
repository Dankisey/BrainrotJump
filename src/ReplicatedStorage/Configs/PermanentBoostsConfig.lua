local RebirthConfig = require(script.Parent.RebirthConfig)

local PermanentBoosts = {}

PermanentBoosts.Boosts = {
    Rebirth = {
        StatsFunctions = {
            Cash = function(level: number)
                return RebirthConfig.Bonus.StartValue + (RebirthConfig.Bonus.Step * (level - 1))
            end;
        };

        IsLevelBased = true;
    };
    Premium = {
        ModifiedStats = {
            JumpPower = 1.5;
        }
    };
}

PermanentBoosts.UiInfo = {
    Rebirth = {
		Icon = "rbxassetid://124789088886644";
        TooltipInfo = function(level: number)
            return {
                Type = "Default";
                Text = "<font color='#" .. Color3.fromRGB(41, 250, 48):ToHex() .. "'>+" ..
                math.round((PermanentBoosts.Boosts.Rebirth.StatsFunctions.Cash(level) - 1) * 100) .. "%</font> Cash";
            }
        end;
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