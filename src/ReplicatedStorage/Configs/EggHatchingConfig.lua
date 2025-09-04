local EggHatchingConfig = {}

EggHatchingConfig.Rotations = {
	[1] = Vector3.new(0, 0, -15);
	[2] = Vector3.new(0, 0, 45);
	[3] = Vector3.new(0, 0, -20);
	[4] = Vector3.new(0, 0, 40);
	[5] = Vector3.new(0, 0, 0);
}

EggHatchingConfig.RotatingTime = .1
EggHatchingConfig.TimeBetweenRotations = .05

EggHatchingConfig.FarPositionOffest = Vector3.new(0, -10, -1)
EggHatchingConfig.NearPositionOffset = Vector3.new(0, 0, -2)

EggHatchingConfig.WhiteFrameDisappearingTime = .4
EggHatchingConfig.MinOffsetFromCamera = -8

return EggHatchingConfig