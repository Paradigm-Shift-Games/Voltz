-- Abstract gun class

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Tool = require(script.Parent)
local SpringHandler = require(script.SpringHandler)

local Gun = setmetatable({}, Tool)
Gun.__index = Gun

type gunConfig = {
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

-- private:

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local bulletContainer = Instance.new("Folder")
bulletContainer.Name = "Bullets"
bulletContainer.Parent = workspace

local function tweenOnce(...): Tween
	local tween = TweenService:Create(...)
	tween:Play()
	local connection
	connection = tween.Completed:Connect(function()
		connection:Disconnect()
		tween:Destroy()
	end)
	
	return tween
end


-- static:

-- Default config, can be overwritten per gun
Gun.Config = {
	AutoFire = false,
	FireRate = 1.5,
	Bloom = 0.9,
	Range = 192,
	BulletsPerShot = 3,
	DelayPerShot = 0,
	Damage = 20,
	ScopeFOV = 60,
	BulletDecoration = {
		Color = Color3.fromRGB(245, 205, 48),
		Thickness = 0.25,
		BulletSpeed = 10,
	}
}

function Gun.DrawShot(startPoint: Vector3, endPoint: Vector3, config: table)
	config = config or Gun.Config

	local thickness = config.BulletDecoration.Thickness
	local distance = math.min(config.Range, (startPoint - endPoint).Magnitude)

	local beam = Instance.new("Part", workspace)
	beam.Color = config.BulletDecoration.Color
	beam.FormFactor = "Custom"
	beam.Material = Enum.Material.Neon
	beam.Anchored = true
	beam.Locked = true
	beam.CanCollide = false
	beam.CanQuery = false
	beam.CanTouch = false
	beam.Size = Vector3.new(thickness, thickness, distance)
	beam.CFrame = CFrame.new(startPoint, endPoint) * CFrame.new(0, 0, -distance / 2)

	local mesh = Instance.new("BlockMesh")
	mesh.Parent = beam
	beam.Parent = bulletContainer

	local travelSpeed = (distance/300) / (config.BulletDecoration.BulletSpeed or 1)
	Debris:AddItem(beam, travelSpeed)

	task.delay(1/30, function()
		tweenOnce(mesh, TweenInfo.new(travelSpeed - 1/30, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = Vector3.new(1, 1, 0), Offset = Vector3.new(0, 0, -distance/2)})
	end)
end

function Gun.PlaySound(tool: Tool, config: gunConfig)
	if not config.FireSound then
		return
	end

	local handle: Part? = tool:FindFirstChild("Handle")
	if not handle then
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = "Fire"

	--[[ 
		This loop currently skips over tables
		It would be neat if in the future FireSound would have support for SoundEffects
		And that it would be set up like so:
		FireSound = {
			SoundId = "...",
			Volume = 0.5,
			PitchShiftSoundEffect = {
				Octave = 1.2,
				Priority = 0
			}
		}
	]]
	for property, value in config.FireSound do
		if type(value) == "table" then
			continue
		end
		sound[property] = value
	end

	sound.Parent = handle
	sound:Play()
	Debris:AddItem(sound, (sound.TimeLength ~= 0 and sound.TimeLength) or 10)
end

function Gun.EmitFlare(tool: Tool)
	local bulletSpawn: Attachment? = tool:FindFirstChild("BulletSpawn", true)
	if not bulletSpawn then
		return
	end

	local flare: ParticleEmitter? = bulletSpawn:FindFirstChild("Flare")
	local light: PointLight? = bulletSpawn:FindFirstChild("Light")

	if flare then
		flare:Emit(16)
	end

	if light then
		local clone = light:Clone()
		clone.Name = "tmp"
		clone.Enabled = true
		clone.Parent = bulletSpawn
		Debris:AddItem(clone, 0.05)
	end
end

-- public:

function Gun:GetRaycastBlacklist(): Array<Instance>
	-- PLEASE ADD BLUEPRINTS HERE PLEASE
	return {self.Instance, localPlayer.Character, bulletContainer}
end

function Gun:GetConfigValue(valueName: string): any?
	local config = self.Config
	return config[valueName]
end

function Gun:GetMousePosition(raycastParams: RaycastParams): Vector3
	local cameraPosition = workspace.CurrentCamera.CFrame.Position
	local direction = (mouse.Hit.Position - cameraPosition).Unit*2048
	local raycastResult = workspace:Raycast(cameraPosition, direction, raycastParams)
	return (raycastResult and raycastResult.Position) or mouse.Hit.Position
end

function Gun:OnActivated()
	if self.Active then
		return
	end

	local fireRate = self:GetConfigValue("FireRate")
	local deltaShootTime = (os.clock() - self.LastShotFiredTime)
	if deltaShootTime < 1/fireRate then
		return
	end

	local initTime = os.clock()
	self.Active = true
	self.ActivationTime = initTime

	local bulletsPerShot = self:GetConfigValue("BulletsPerShot")
	local delayPerShot = self:GetConfigValue("DelayPerShot") or 0
	local bloom = self:GetConfigValue("Bloom")
	local range = self:GetConfigValue("Range")
	local decoration = self:GetConfigValue("BulletDecoration")

	local bulletSpawn = self.Instance:FindFirstChild("BulletSpawn", true)
	assert(bulletSpawn, "BulletSpawn instance not found for: " .. self.Instance:GetFullName())

	local blacklist = self:GetRaycastBlacklist()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = blacklist

	local function fireShot()
		for i = 1, bulletsPerShot do
			if not self.Instance.Parent then
				break
			end

			local startPosition = bulletSpawn.WorldPosition
			local hit = self:GetMousePosition(raycastParams)
			
			local r0, r1 = self.Random:NextNumber(), self.Random:NextNumber()^1.2

			local direction = (
				CFrame.new(startPosition, hit) 
				* CFrame.Angles(0, 0, math.pi * 2 * r0) 
				* CFrame.Angles(math.rad(bloom/2) * r1, 0, 0)
			).LookVector * range

			local raycastResult = workspace:Raycast(startPosition, direction, raycastParams)
			local endPosition: Vector3

			if raycastResult then
				endPosition = raycastResult.Position
			else
				endPosition = startPosition+direction
			end

			-- Draw a secondary ray from the head to prevent guns from firing through walls when the barrel is on the other side.
			local headPosition = localPlayer.Character.Head.Position
			local headDirection = (endPosition - headPosition).Unit * range
			local raycastResultFromHead = workspace:Raycast(headPosition, headDirection, raycastParams)
			if raycastResultFromHead then
				endPosition = raycastResultFromHead.Position
			end

			if i == 1 or delayPerShot > 0 then
				SpringHandler:Impulse(localPlayer.Character, decoration.ImpulseForce or 10)
				self.PlaySound(self.Instance, self.Config)
				self.EmitFlare(self.Instance)
				self.LastShotFiredTime = os.clock()
			end

			self.DrawShot(startPosition, endPosition, self.Config)
			if delayPerShot ~= 0 then
				task.wait(delayPerShot)
			end
		end
	end
	fireShot()

	local shotsFired = 1
	local renderId = "FireGun-" .. initTime
	RunService:BindToRenderStep(renderId, Enum.RenderPriority.Input.Value+1, function(deltaTime)
		if not self.Active or self.ActivationTime ~= initTime then
			RunService:UnbindFromRenderStep(renderId)
			return
		end

		local timeFiring = os.clock() - self.ActivationTime
		local requiredShotCount = math.floor(timeFiring/(1/fireRate))
		local offset = deltaTime

		if shotsFired > requiredShotCount then
			offset = 0
		end

		local t = os.clock()
		local deltaShootTime = (os.clock() - self.LastShotFiredTime + offset)
		if deltaShootTime < 1/fireRate then
			return
		end

		local shotAmount = 1

		print("deltaShotCount", shotsFired - requiredShotCount)

		if requiredShotCount > shotsFired then
			shotAmount = 1 + (requiredShotCount - shotsFired)
		end

		for i = 1, shotAmount do
			shotsFired += 1
			fireShot()
		end
	end)
end

function Tool:OnDeactivated()
	self.Active = false
end

function Tool:OnUnequipped()
	self.Active = false
end

function Gun.new(instance: Tool)
	local self = setmetatable(Tool.new(instance), Gun)
	self.Random = Random.new((os.clock()%1) * 1e9)
	self.LastShotFiredTime = 0

	return self
end

return Gun