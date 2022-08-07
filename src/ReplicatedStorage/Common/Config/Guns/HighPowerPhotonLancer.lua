local HighPowerPhotonLancerConfig = {
	FireRate = 0.125,
	Bloom = 0,
	Range = 1024,
	BulletsPerShot = 1,
	Damage = 65,
	IridiumCost = 100,
	ScopeFOV = 40,
	BulletDecoration = {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 0.35
	},
	FireSound = {
		SoundId = "rbxassetid://181593315",
		Volume = 0.8,
		DistortionSoundEffect = {
			Level = 0.75
		},
		FlangeSoundEffect = {
			Depth = 0.5,
			Mix = 1,
			Priority = 0,
			Rate = 5
		},
		PitchShiftSoundEffect = {
			Octave = 0.5,
			Priority = 0
		}
	}
}

return HighPowerPhotonLancerConfig