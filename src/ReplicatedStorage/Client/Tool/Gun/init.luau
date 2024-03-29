-- Abstract gun class

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Tool = require(script.Parent)
local SpringHandler = require(script.SpringHandler)
local Trove = require(ReplicatedStorage.Packages.Trove)
local GunDataTypes = require(ReplicatedStorage.Common.Types.GunDataTypes)

local Gun = setmetatable({}, Tool)
Gun.__index = Gun

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

function Gun:_fireBulletData(bulletDataList)
	local BulletHandlerService = Knit.GetService("BulletHandlerService")
	BulletHandlerService:FireBullet(bulletDataList)
end

function Gun:_createGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GunGui"

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(100, 100)
	frame.BackgroundTransparency = 1
	frame.AnchorPoint = Vector2.new(0.5, 0.5)

	frame.Parent = screenGui
	screenGui.Parent = localPlayer.PlayerGui

	self._baseFrame = frame
	self._trove:Add(screenGui)
	
	local renderId = "GunGui-"..os.clock()
	self._trove:BindToRenderStep(renderId, Enum.RenderPriority.Input.Value+1, function()
		frame.Position = UDim2.fromOffset(mouse.X, mouse.Y)
	end)
end

function Gun:_isCritPart(hitPart: BasePart)
	return (hitPart.Name == "Head")
end

function Gun:StartReloadBarEffect(duration)
	if self._activeReloadBarValue then
		self._activeReloadBarValue:Destroy()
	end
	local numberValue = Instance.new("NumberValue")
	numberValue.Name = "ReloadBarValue"
	numberValue.Value = 0
	self._activeReloadBarValue = numberValue
	tweenOnce(numberValue, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Value = 1})
	self:ShowReloadBar()
end

function Gun:ShowReloadBar()
	local numberValue = self._activeReloadBarValue
	if not numberValue then
		return
	end
	if self._activeReloadFrame then
		self._activeReloadFrame:Destroy()
	end

	local frame = Instance.new("Frame")
	frame.Name = "ReloadBar"
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, 73)
	frame.Size = UDim2.fromOffset(65, 3)

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 16)

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = frame.BackgroundColor3
	UIStroke.Thickness = 1
	UIStroke.Transparency = 0.2

	UIStroke.Parent = frame
	UICorner.Parent = frame
	frame.Parent = self._baseFrame
	self._activeReloadFrame = frame

	numberValue.Changed:Connect(function()
		local t = numberValue.Value
		frame.Size = UDim2.fromOffset(100*(1-t), 3)
		if t >= 1 then
			frame:Destroy()
			numberValue:Destroy()
			self._activeReloadBarValue = nil
		end
	end)
end

function Gun:ShowHitmarker(isCrit: boolean?)
	local hitmarker = Instance.new("ImageLabel")
	hitmarker.Name = "Hitmarker"
	hitmarker.ZIndex = (isCrit and 3) or 2
	hitmarker.BackgroundTransparency = 1
	hitmarker.Size = UDim2.fromScale(0, 0)
	hitmarker.Position = UDim2.fromScale(0.5, 0.5)
	hitmarker.AnchorPoint = Vector2.new(0.5, 0.5)
	hitmarker.Image = "rbxassetid://6113601434"
	hitmarker.ImageTransparency = 0.1
	hitmarker.ImageColor3 = (isCrit and Color3.fromRGB(255, 0, 0)) or Color3.fromRGB(255, 255, 255)
	hitmarker.Parent = self._baseFrame

	Debris:AddItem(hitmarker, 0.4)
	tweenOnce(hitmarker, TweenInfo.new(0.1), {Size = UDim2.fromOffset(50, 50)})
	task.delay(0.3, function()
		tweenOnce(hitmarker, TweenInfo.new(0.1), {Size = UDim2.fromOffset(0, 0)})
	end)
end

function Gun:ShowHitmarkerFromHitPart(hitPart: BasePart?)
	if not hitPart or not hitPart.Parent then
		return
	end

	local character = hitPart.Parent
	local humanoid = character.Parent and character:FindFirstChild("Humanoid")
	if humanoid then
		local isCrit = self:_isCritPart(hitPart)
		self:ShowHitmarker(isCrit)
	end
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

function Gun.DrawShot(startAttachment: Attachment, endPoint: any, gunConfig: GunDataTypes.GunConfig)
	gunConfig = gunConfig or Gun.Config

	local endPointPosition = (typeof(endPoint) == "Vector3" and endPoint) or endPoint.Position

	local startPoint = startAttachment.WorldPosition
	local thickness = gunConfig.BulletDecoration.Thickness
	local distance = math.min(gunConfig.Range, (startPoint - endPointPosition).Magnitude)

	local beam = Instance.new("Part", workspace)
	beam.Color = gunConfig.BulletDecoration.Color
	beam.FormFactor = "Custom"
	beam.Material = Enum.Material.Neon
	beam.Anchored = true
	beam.Locked = true
	beam.CanCollide = false
	beam.CanQuery = false
	beam.CanTouch = false
	beam.CastShadow = false
	beam.Size = Vector3.new(thickness, thickness, distance)

	local mesh = Instance.new("BlockMesh")
	mesh.Parent = beam

	local travelSpeed = (distance/300) / (gunConfig.BulletDecoration.BulletSpeed or 1)
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
		if typeof(endPoint) ~= "Vector3" then
			endPointPosition = endPoint.Position
		end
		beam.CFrame = CFrame.lookAt(startPoint, endPointPosition) * CFrame.new(0, 0, -distance / 2 - 0.1)
	end
	RunService:BindToRenderStep(renderId, 0, update)
	task.spawn(update, 0)

	beam.Parent = bulletContainer
end

function Gun.PlaySound(tool: Tool, config: GunDataTypes.GunConfig)
	if not config.FireSound then
		return
	end

	local handle: Part? = tool:FindFirstChild("Handle")
	if not handle then
		return
	end

	local sound = Instance.new("Sound")
	sound.Name = "Fire"

	for property, value in config.FireSound do
		if type(value) == "table" then
			local soundEffect = Instance.new(property)
			for k, v in value do
				soundEffect[k] = v
			end
			soundEffect.Parent = sound
		else
			sound[property] = value
		end
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
	local blacklist = {self.Instance, localPlayer.Character, bulletContainer}
	if extraInstances then
		for _, instance in ipairs(extraInstances) do
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
		local bulletDataList: Array<GunDataTypes.BulletData> = {}
		self:StartReloadBarEffect(1/self.Config.FireRate)
		self.LastShotFiredTime = os.clock()

		for i = 1, bulletsPerShot do
			if not self.Instance.Parent then
				break
			end

			local startPosition = bulletSpawn.WorldPosition
			local hit = self:GetMousePosition(raycastParams)
			
			local r0, r1 = self.Random:NextNumber(), self.Random:NextNumber()

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
			local originalEndPosition = endPosition

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
			end

			local bulletData: GunDataTypes.BulletData = {
				BarrelPosition = startPosition,
				EndPosition = endPosition,
				ToolName = self.Instance.Name
			}

			if raycastResult and endPosition == originalEndPosition then
				bulletData.HitPart = raycastResult.Instance
				if delayPerShot ~= 0 then
					self:ShowHitmarkerFromHitPart(bulletData.HitPart)
				else

				end
			end

			table.insert(bulletDataList, bulletData)

			self.DrawShot(bulletSpawn, endPosition, self.Config)
			if delayPerShot ~= 0 then
				self:_fireBulletData(bulletDataList)
				bulletDataList = {}
				task.wait(delayPerShot)
			end
		end

		if delayPerShot == 0 then
			self:_fireBulletData(bulletDataList)
			local critCount = 0
			local hitCount = 0
			for _, bulletData: GunDataTypes.BulletData in bulletDataList do
				local hitPart = bulletData.HitPart
				if not hitPart then
					continue
				end

				local character = hitPart.Parent
				local humanoid = character and character:FindFirstChild("Humanoid")
				if humanoid then
					if self:_isCritPart(hitPart) then
						critCount += 1
					else
						hitCount += 1
					end
				end
			end

			if critCount ~= 0 or hitCount ~= 0 then
				self:ShowHitmarker(critCount >= hitCount)
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

function Tool:OnEquipped()
	if self._trove then
		self._trove:Clean()
	end
	self._trove = Trove.new()
	self:_createGui()
	self.Active = false
	self:ShowReloadBar()
end

function Tool:OnDeactivated()
	self.Active = false
end

function Tool:OnUnequipped()
	if self._trove then
		self._trove:Clean()
	end
	self.Active = false
end

function Gun.new(instance: Tool)
	local self = setmetatable(Tool.new(instance), Gun)
	self.Random = Random.new((os.clock()%1) * 1e9)
	self.LastShotFiredTime = 0

	return self
end

return Gun
