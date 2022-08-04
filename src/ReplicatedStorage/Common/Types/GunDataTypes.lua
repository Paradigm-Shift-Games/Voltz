--!strict

export type GunConfig = {
    AutoFire: boolean,
	FireRate: number,
	Bloom: number,
	Range: number,
	BulletsPerShot: number,
	DelayPerShot: number,
	Damage: number,
	ScopeFOV: number,
	BulletDecoration: {
		Color: Color3,
		Thickness: number,
		BulletSpeed: number
	},
	FireSound: {
		SoundId: string,
		Volume: number
	}?
}

export type BulletData = {
    BarrelPosition: Vector3,
    EndPosition: Vector3,
    ToolName: string,
    HitPart: Instance?
}

return nil