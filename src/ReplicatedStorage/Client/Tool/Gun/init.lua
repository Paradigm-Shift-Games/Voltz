-- Abstract gun class

local CollectionService = game:GetService("CollectionService")
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

function Gun.DrawShot(startAttachment: Attachment, endPoint: Vector3, config: table)
	config = config or Gun.Config

	local startPoint = startAttachment.WorldPosition
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

	local mesh = Instance.new("BlockMesh")
	mesh.Parent = beam

	local travelSpeed = (distance/300) / (config.BulletDecoration.BulletSpeed or 1)
	Debris:AddItem(beam, travelSpeed)

	task.delay(1/30, function()
		tweenOnce(mesh, TweenInfo.new(travelSpeed - 1/30, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = Vector3.new(1, 1, 0), Offset = Vector3.new(0, 0, -distance/2)})
	end)

	-- BeamUpdater updates the beam's cframe for 0.1 seconds so it doesn't look weird when the character moves a lot
	local renderId = "BeamUpdater-"..os.clock()
	local endTime = os.clock() + 0.1
	local function update()
		if not beam.Parent or not startAttachment.Parent or os.clock() > endTime then
			RunService:UnbindFromRenderStep(renderId)
			return
		end
		startPoint = startAttachment.WorldPosition
		beam.CFrame = CFrame.lookAt(startPoint, endPoint) * CFrame.new(0, 0, -distance / 2 - 0.1)
	end
	RunService:BindToRenderStep(renderId, 0, update)
	task.spawn(update, 0)

	beam.Parent = bulletContainer
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

function Gun:GetRaycastBlacklist(extraInstances: Array<Instance>?): Array<Instance>
	-- PLEASE ADD BLUEPRINTS HERE PLEASE
	local blacklist = {self.Instance, localPlayer.Character, bulletContainer}
	if extraInstances then
		for _, instance in extraInstances do
			table.insert(blacklist, instance)
		end
	end
	return blacklist
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

	local blacklistForSanityChecks = self:GetRaycastBlacklist(CollectionService:GetTagged("Character"))
	local raycastParamsForSanityChecks = RaycastParams.new()
	raycastParamsForSanityChecks.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParamsForSanityChecks.FilterDescendantsInstances = blacklistForSanityChecks

	local function rayCheckForCharacter(bulletHitPosition: Vector3, characterPosition: Vector3, forwardCharacterCheckDistance: number?): Vector3?
		local distance = (bulletHitPosition - characterPosition).Magnitude
		forwardCharacterCheckDistance = math.min(distance, forwardCharacterCheckDistance)

		local lookAtDirection = (characterPosition - bulletHitPosition).Unit*forwardCharacterCheckDistance
		local endCheckPosition = characterPosition-lookAtDirection

		local raycastResult = workspace:Raycast(endCheckPosition, lookAtDirection, raycastParamsForSanityChecks)
		if raycastResult then
			return raycastResult.Position
		end
	end

	local function fireShot()
		for i = 1, bulletsPerShot do
			if not self.Instance.Parent then
				break
			end

			local startPosition = bulletSpawn.WorldPosition
			local hit = self:GetMousePosition(raycastParams)
			
			local r0, r1 = self.Random:NextNumber(), self.Random:NextNumber()^1.2

			local direction = (
				CFrame.lookAt(startPosition, hit) 
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

			-- Draws reversed rays from the Head and RightUpperArm to prevent guns from firing through walls when the barrel is on the other side.
			-- Also fires an extra reversed ray to bulletSpawn's position to check if the original ray missed an object
			local headCheckPosition = rayCheckForCharacter(endPosition, localPlayer.Character.Head.Position, 32)
			local shoulderCheckPosition = rayCheckForCharacter(endPosition, localPlayer.Character.RightUpperArm.Position, 32)
			local inversedBarrelCheckPosition = rayCheckForCharacter(endPosition, startPosition, self.Config.Range)

			if inversedBarrelCheckPosition then
				endPosition = inversedBarrelCheckPosition
			elseif headCheckPosition and shoulderCheckPosition then
				endPosition = shoulderCheckPosition
			end

			if i == 1 or delayPerShot > 0 then
				SpringHandler:Impulse(localPlayer.Character, decoration.ImpulseForce or 10)
				self.PlaySound(self.Instance, self.Config)
				self.EmitFlare(self.Instance)
				self.LastShotFiredTime = os.clock()
			end

			self.DrawShot(bulletSpawn, endPosition, self.Config)
			if delayPerShot ~= 0 then
				task.wait(delayPerShot)
			end
		end
	end
	fireShot()

	local shotsFired = 1
	local renderId = "FireGun-" .. initTime
	RunService:BindToRenderStep(renderId, Enum.RenderPriority.Input.Value + 1, function(deltaTime)
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