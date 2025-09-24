local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BrainrotConfig = {}

--[[
 go to https://cubic-bezier.com to edit curve
 ]]
BrainrotConfig.BezierUp = {
    X1 = 0;
    Y1 = .9;
    X2 = .59;
    Y2 = .99;
};

BrainrotConfig.BezierDown = {
    X1 = .26;
    Y1 = .05;
    X2 = .78;
    Y2 = -0.12;
};

--[[=======================================]]
BrainrotConfig.CheckpointBaseHeight = 200;
BrainrotConfig.CheckpointHeightMultiplier = 10;
BrainrotConfig.Speed = 50; -- studs per second
BrainrotConfig.MaxTimePerCheckpoint = 10;

BrainrotConfig.JumpEffectParameters = {
    PreJumpMinIntensity = 0.01;
    PreJumpMaxIntensity = 0.13;
    PostJumpShakeIntensity = 0.5;
    PostJumpShakeDuration = .5;
    DelayToDisableJumpGui = 3;
}

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