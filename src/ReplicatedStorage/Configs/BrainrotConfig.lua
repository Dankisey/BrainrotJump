local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BrainrotConfig = {}

BrainrotConfig.CheckpointBaseHeight = 200;
BrainrotConfig.CheckpointHeightMultiplier = 10;
BrainrotConfig.Speed = 50; -- studs per second

BrainrotConfig.Brainrots = {
    [1] = {
        PublicName = "Avocadini Guffo";
        Icon = "";
        XpToNextLevel = 200;
        Model = ReplicatedStorage.Assets.Brainrot.AvocadiniGuffo;
        MinJumpPower = 10;
        MaxJumpPower = 100;
    };
    [2] = {
        PublicName = "Frigo Camelo";
        Icon = "";
        XpToNextLevel = 400;
        Model = ReplicatedStorage.Assets.Brainrot.FrigoCamelo ;
        MinJumpPower = 100;
        MaxJumpPower = 200;
    };
}

return BrainrotConfig