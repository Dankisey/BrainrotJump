local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Bezier = require(ReplicatedStorage.Modules.Utils.CubicBezier)
local BrainrotConfig = {}

--[[
 go to https://cubic-bezier.com to edit curve
 ]]
BrainrotConfig.BezierUp = Bezier.new(0,.9,.58,.99);
BrainrotConfig.BezierDown = Bezier.new(.31,.23,.45,1);

--[[=======================================]]
BrainrotConfig.CheckpointBaseHeight = 200;
BrainrotConfig.CheckpointHeightMultiplier = 10;
BrainrotConfig.Speed = 50; -- studs per second
BrainrotConfig.MaxTimePerCheckpoint = 10;

BrainrotConfig.JumpEffectParameters = {
    PreJumpMinIntensity = 0.01;
    PreJumpMaxIntensity = 0.13;
    PostJumpShakeIntensity = 0.5;
    PostJumpShakeDuration = .3;
    DelayToDisableJumpGui = 3;
}

BrainrotConfig.Brainrots = {
    [1] = {
        PublicName = "Avocadini Guffo";
        Icon = "";
        XpToNextLevel = 200;
        Model = ReplicatedStorage.Assets.Brainrot.AvocadiniGuffo;
        MinJumpPower = 100;
        MaxJumpPower = 150;
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