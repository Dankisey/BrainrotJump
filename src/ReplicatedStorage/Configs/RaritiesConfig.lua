local RaritiesConfig = {
    Common = {
        PublicName = "Common";
        Name = "Common";
        Color = Color3.fromRGB(255, 255, 255);
        IndexFrameColor = Color3.fromRGB(128, 128, 128);
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.52, Color3.fromRGB(206, 206, 203)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(155, 156, 143))
        });
        Index = 1;
    };
    Uncommon = {
        PublicName = "Uncommon";
        Name = "Uncommon";
        Color = Color3.fromRGB(46, 233, 18);
        IndexFrameColor = Color3.fromRGB(46, 233, 18);
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(216, 228, 220)),
            ColorSequenceKeypoint.new(0.52, Color3.fromRGB(147, 231, 143)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(97, 224, 169))
        });
        Index = 2;
    };
    Rare = {
        PublicName = "Rare";
        Name = "Rare";
        Color = Color3.fromRGB(26, 125, 218);
        IndexFrameColor = Color3.fromRGB(26, 125, 218);
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(216, 228, 220)),
            ColorSequenceKeypoint.new(0.52, Color3.fromRGB(143, 210, 231)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(97, 167, 228))
        });
        Index = 3;
    };
    Epic = {
        PublicName = "Epic";
        Name = "Epic";
        Color = Color3.fromRGB(98, 24, 209);
        IndexFrameColor = Color3.fromRGB(98, 24, 209);
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(216, 228, 220)),
            ColorSequenceKeypoint.new(0.52, Color3.fromRGB(231, 143, 227)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(224, 97, 220))
        });
        Index = 4;
    };
    Legendary = {
        PublicName = "Legendary";
        Name = "Legendary";
        Color = Color3.fromRGB(228, 224, 11);
        IndexFrameColor = Color3.fromRGB(228, 224, 11);
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(216, 228, 220)),
            ColorSequenceKeypoint.new(0.52, Color3.fromRGB(231, 169, 143)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(224, 184, 97))
        });
        Index = 5;
    };
    Divine = {
        PublicName = "Divine";
        Name = "Divine";
        Color = Color3.fromRGB(228, 38, 38);
        IndexFrameColor = Color3.fromRGB(228, 38, 38);
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(216, 228, 220)),
            ColorSequenceKeypoint.new(0.52, Color3.fromRGB(231, 143, 143)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(242, 102, 102))
        });
        Index = 6;
    };
}

return RaritiesConfig