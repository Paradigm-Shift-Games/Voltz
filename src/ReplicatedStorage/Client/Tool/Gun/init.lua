-- Abstract gun class
-- Virtual methods must be implemented via sub-classes

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Tool = require(script.Parent)
local SpringHandler = require(script.SpringHandler)

local Gun = {}
Gun.__index = Gun
setmetatable(Gun, Tool)

-- private:

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local bulletContainer = Instance.new("Folder")
bulletContainer.Name = "Bullets"
bulletContainer.Parent = workspace

local function tweenOnce(...)
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
	FireRate = 1/1.5,
	Bloom = 0.9,
	Range = 192,
	BulletsPerShot = 3,
	DelayPerShot = 0.07,
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
	beam.Size = Vector3.new(thickness, thickness, distance)
	beam.CFrame = CFrame.new(startPoint, endPoint) * CFrame.new(0, 0, -distance / 2)

	local mesh = Instance.new("BlockMesh")
	mesh.Parent = beam
	beam.Parent = bulletContainer

	local travelSpeed = (distance/300) / (config.BulletSpeed or 1)
	Debris:AddItem(beam, travelSpeed)

	task.delay(1/30, function()
		tweenOnce(mesh, TweenInfo.new(travelSpeed - 1/30, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = Vector3.new(1, 1, 0), Offset = Vector3.new(0, 0, -distance/2)})
	end)
end

-- public:

function Gun:GetRaycastBlacklist()
	-- PLEASE ADD BLUEPRINTS HERE PLEASE
	return {self.Instance, localPlayer.Character, bulletContainer}
end

function Gun:GetConfigValue(valueName: string)
	return (self.Config and self.Config[valueName]) or Gun.Config[valueName]
end

function Gun:GetMousePosition(raycastParams: RaycastParams)
	local cameraPosition = workspace.CurrentCamera.CFrame.Position
	local direction = (mouse.Hit.Position - cameraPosition).Unit*2048
	local raycastResult = workspace:Raycast(cameraPosition, direction, raycastParams)
	return (raycastResult and raycastResult.Position) or mouse.Hit.Position
end

function Gun:OnActivated()
	local initTime = os.clock()
	self.Active = true
	self.ActivationTime = initTime

	local bulletsPerShot = self:GetConfigValue("BulletsPerShot")
	local delayPerShot = self:GetConfigValue("DelayPerShot")
	local bloom = self:GetConfigValue("Bloom")
	local range = self:GetConfigValue("Range")

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
			
			local r0, r1 = self.Random:NextNumber()^2, self.Random:NextNumber()^2

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

			local bulletHole = Instance.new("Part")
			bulletHole.Anchored = true
			bulletHole.Color = Color3.new(1, 0, 0)
			bulletHole.CanCollide = false
			bulletHole.Size = Vector3.new(0.2, 0.2, 0.2)
			bulletHole.CFrame = CFrame.new(endPosition)
			bulletHole.Material = Enum.Material.Neon
			bulletHole.Shape = Enum.PartType.Ball
			bulletHole.Parent = bulletContainer
			Debris:AddItem(bulletHole, 10)

			SpringHandler:Impulse(localPlayer.Character, 10)

			Gun.DrawShot(startPosition, endPosition, self.Config)
			if delayPerShot and delayPerShot ~= 0 then
				task.wait(delayPerShot)
			end
		end
	end
	fireShot()
end

function Gun.new(instance: Tool)
	local self = Tool.new(instance)
	setmetatable(self, Gun)
	self.Random = Random.new((os.clock()%1) * 1e9)

	return self
end

function Gun:Destroy()

end

return Gun