local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Trove = require(ReplicatedStorage.Packages.Trove)

local CameraLook = {}
CameraLook.__index = CameraLook

local function calculateJointAngle(lookVector, sourcePosition, targetPosition)
	return math.asin((sourcePosition - targetPosition):Dot(lookVector)/(sourcePosition - targetPosition).Magnitude)
end

local easingStyle = Enum.EasingStyle.Circular
local easingDirection = Enum.EasingDirection.In
local function dampenAngle(sourceAngle: number, goalAngle: number, angularSpeed: number, deltaTime: number)
	local angleDiff = goalAngle % math.rad(360) - sourceAngle % math.rad(360)
	if math.abs(angleDiff) > math.rad(180) then
		local dividend = math.sign(angleDiff) * math.rad(180)
		angleDiff = angleDiff%dividend - dividend
	end
	return sourceAngle + math.sign(angleDiff) * TweenService:GetValue(math.clamp(math.min(angularSpeed, math.abs(angleDiff/deltaTime) / angularSpeed), 0, 1), easingStyle, easingDirection) * angularSpeed * deltaTime
end

local function clampedAngles(angles: Vector3, pitchClamp: Vector3, yawClamp: Vector3, rollClamp: Vector3)
	return CFrame.Angles(
		math.clamp(angles.X, pitchClamp.X, pitchClamp.Y),
		math.clamp(angles.Y, yawClamp.X, yawClamp.Y),
		math.clamp(angles.Z, rollClamp.X, rollClamp.Y)
	)
end

function CameraLook.new(instance: Instance)
	local self = setmetatable({}, CameraLook)

	self.Instance = instance
	self._trove = Trove.new()

	-- Wait for Humanoid to be added
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")
	while not humanoid do
		humanoid = instance:FindFirstChildWhichIsA("Humanoid")
		instance.ChildAdded:Wait()
	end

	-- Retrieve player root part
	local rootPart = humanoid.RootPart

	-- Speed for rotating the character itself
	self.LookAngularSpeed = math.rad(400)

	-- Disable automatic rotation
	humanoid.AutoRotate = false

	-- Speed for rotating the root
	self.RootPitchSpeed = math.rad(80)
	self.RootYawSpeed = math.rad(0)
	self.RootPitchBounds = Vector3.new(-55, 20) * math.rad(1)
	self.RootYawBounds = Vector3.new(-30, 30) * math.rad(1)
	self.RootRollBounds = Vector3.new()

	-- Speed for rotating the waist
	self.WaistPitchSpeed = math.rad(100)
	self.WaistYawSpeed = math.rad(360)
	self.WaistPitchBounds = Vector3.new(-55, 30) * math.rad(1)
	self.WaistYawBounds = Vector3.new(-35, 35) * math.rad(1)
	self.WaistRollBounds = Vector3.new()

	-- Speed for rotating the neck
	self.NeckPitchSpeed = math.rad(200)
	self.NeckYawSpeed = math.rad(560)
	self.NeckPitchBounds = Vector3.new(-35, 25) * math.rad(1)
	self.NeckYawBounds = Vector3.new(-45, 45) * math.rad(1)
	self.NeckRollBounds = Vector3.new()

	-- Grab base C0 for root part (TODO: Clean this up)
	local lowerTorso: BasePart = instance:WaitForChild("LowerTorso")
	local root: Motor6D = lowerTorso and lowerTorso:WaitForChild("Root")
	local rootC0 = root.C0

	-- Reset joint angles
	self._rootAngles = Vector3.new()
	self._waistAngles = Vector3.new()
	self._neckAngles = Vector3.new()

	local player: Player? = Players:GetPlayerFromCharacter(instance)
	local isLocalPlayer = player == Players.LocalPlayer
	local mouse: Mouse? = if isLocalPlayer then player:GetMouse() else nil
	self._trove:Connect(RunService.Stepped, function(_, deltaTime)
		-- Get root CFrame & vectors
		local cframe = rootPart:GetPivot()

		local upVector = cframe.UpVector
		local rightVector = cframe.RightVector

		-- Locate mouse target part
		local lookPart: BasePart = instance:FindFirstChild("MouseTarget")
		local lookCFrame
		if isLocalPlayer then
			-- Use the mouse's CFrame
			lookCFrame = mouse.Hit

			-- Set target part CFrame
			if lookPart then
				lookPart.CFrame = lookCFrame
			end
		else
			-- Use the look part's CFrame, and fall back to root's CFrame
			if lookPart then
				lookCFrame = lookPart.CFrame
			else
				lookCFrame = cframe
			end
		end

		-- Determine the look position
		local lookPosition = lookCFrame.Position

		-- Root joint angles
		local lowerTorso: BasePart? = instance:FindFirstChild("LowerTorso")
		local root: Motor6D? = lowerTorso and lowerTorso:FindFirstChild("Root")
		if root then
			self._rootAngles = Vector3.new(
				dampenAngle(self._rootAngles.X, calculateJointAngle(-upVector, lowerTorso.Position, lookPosition), self.RootPitchSpeed, deltaTime),
				dampenAngle(self._rootAngles.Y, calculateJointAngle(rightVector, lowerTorso.Position, lookPosition), self.RootYawSpeed, deltaTime)
			)

			local rootTransform = clampedAngles(self._rootAngles, self.RootPitchBounds, self.RootYawBounds, self.RootRollBounds)
			root.Transform *= rootTransform
			root.C0 = rootC0 * rootTransform:Inverse()
		end

		-- Waist joint angles
		local upperTorso: BasePart? = instance:FindFirstChild("UpperTorso")
		local waist: Motor6D? = upperTorso and upperTorso:FindFirstChild("Waist")
		if waist then
			self._waistAngles = Vector3.new(
				dampenAngle(self._waistAngles.X, calculateJointAngle(-upVector, upperTorso.Position, lookPosition), self.WaistPitchSpeed, deltaTime),
				dampenAngle(self._waistAngles.Y, calculateJointAngle(rightVector, upperTorso.Position, lookPosition), self.WaistYawSpeed, deltaTime)
			)

			waist.Transform *= clampedAngles(self._waistAngles, self.WaistPitchBounds, self.WaistYawBounds, self.WaistRollBounds)
		end

		-- Neck joint angles
		local head: BasePart? = instance:FindFirstChild("Head")
		local neck: Motor6D? = head and head:FindFirstChild("Neck")
		if neck then
			self._neckAngles = Vector3.new(
				dampenAngle(self._neckAngles.X, calculateJointAngle(-upVector, head.Position, lookPosition), self.NeckPitchSpeed, deltaTime),
				dampenAngle(self._neckAngles.Y, calculateJointAngle(rightVector, head.Position, lookPosition), self.NeckYawSpeed, deltaTime)
			)

			neck.Transform *= clampedAngles(self._neckAngles, self.NeckPitchBounds, self.NeckYawBounds, self.NeckRollBounds)
		end

		if isLocalPlayer then
			-- Y rotation
			local x, angle, z = cframe:ToOrientation()
			angle = dampenAngle(angle, math.atan2(lookPosition.X - cframe.X, lookPosition.Z - cframe.Z) + math.rad(180), self.LookAngularSpeed, deltaTime)

			local newOrientation = CFrame.fromOrientation(x, angle, z)
			if humanoid:GetState() == Enum.HumanoidStateType.Running then
				rootPart:PivotTo(CFrame.fromMatrix(cframe.Position, newOrientation.XVector, newOrientation.YVector, newOrientation.ZVector))
			end
		end
	end)

	return self
end

function CameraLook:Destroy()
	self._trove:Clean()
end

return CameraLook