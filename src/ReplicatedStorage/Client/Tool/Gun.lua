-- Abstract gun class
-- Virtual methods must be implemented via sub-classes

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Tool = require(script.Parent)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Gun = {}
Gun.__index = Gun
setmetatable(Gun, Tool)

-- private

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


-- static

-- Default config, can be overwritten per gun
Gun.Config = {
	AutoFire = false,
	FireRate = 1/1.5,
	Bloom = 1.3,
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
	local mesh = Instance.new("BlockMesh")

	local beam = Instance.new("Part", workspace)
	beam.Color = config.BulletDecoration.Color
	beam.FormFactor = "Custom"
	beam.Material = Enum.Material.Neon
	beam.Anchored = true
	beam.Locked = true
	beam.CanCollide = false
	beam.Size = Vector3.new(thickness, thickness, distance)
	beam.CFrame = CFrame.new(startPoint, endPoint) * CFrame.new(0, 0, -distance / 2)
	beam.Parent = bulletContainer
	mesh.Parent = beam
	
	local travelSpeed = (distance/300) / (config.BulletSpeed or 1)
	Debris:AddItem(beam, travelSpeed)

	tweenOnce(mesh, TweenInfo.new(travelSpeed - 1/30, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = Vector3.new(1, 1, 0), Offset = Vector3.new(0, 0, -distance/2)})
end

-- public

function Gun:GetRaycastBlacklist()
	-- PLEASE ADD BLUEPRINTS HERE PLEASE
end

function Gun:GetConfigValue(valueName: string)
	return (self.Config and self.Config[valueName]) or Gun.Config[valueName]
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

	local function fireShot()
		for i = 1, bulletsPerShot do
			if not self.Instance.Parent then
				break
			end

			local startPosition = bulletSpawn.WorldPosition
			local hit = mouse.Hit.Position

			local direction = (
				CFrame.new(startPosition, hit) 
				* CFrame.Angles(0, 0, math.pi * 2 * self.Random:NextNumber()) 
				* CFrame.Angles(math.rad(bloom/2) * self.Random:NextNumber(), 0, 0)
			).LookVector * range

			Gun.DrawShot(startPosition, mouse.Hit.Position, self.Config)
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