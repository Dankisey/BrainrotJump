local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BrainrotConfig = {}

BrainrotConfig.Brainrots = {
    [1] = {
        PublicName = "Avocadini Guffo";
        Icon = "";
        XpToNextLevel = 200;
        Model = ReplicatedStorage.Assets.Brainrot.AvocadiniGuffo;
        MaxJumpPower = 100;
    };
    [2] = {
        PublicName = "Frigo Camelo";
        Icon = "";
        XpToNextLevel = 400;
        Model = ReplicatedStorage.Assets.Brainrot.FrigoCamelo ;
        MaxJumpPower = 200;
    };
}

return BrainrotConfig