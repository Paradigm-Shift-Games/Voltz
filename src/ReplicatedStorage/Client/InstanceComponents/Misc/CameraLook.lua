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

local easingStyle = Enum.EasingStyle.Quint
local easingDirection = Enum.EasingDirection.In
local function dampenAngle(sourceAngle: number, goalAngle: number, angularSpeed: number, deltaTime: number)
	local angleDiff = goalAngle % math.rad(360) - sourceAngle % math.rad(360)
	if math.abs(angleDiff) > math.rad(180) then
		local dividend = math.sign(angleDiff) * math.rad(180)
		angleDiff = angleDiff%dividend - dividend
	end
	return sourceAngle + math.sign(angleDiff) * TweenService:GetValue(math.clamp(math.min(angularSpeed, math.abs(angleDiff/deltaTime) / angularSpeed), 0, 1), easingStyle, easingDirection) * angularSpeed * deltaTime
end

local function dampenAngles(sourceAngles: Vector3, goalAngles: Vector3, angularSpeed: Vector3, deltaTime: number)
	return Vector3.new(
		dampenAngle(sourceAngles.X, goalAngles.X, angularSpeed.X, deltaTime),
		dampenAngle(sourceAngles.Y, goalAngles.Y, angularSpeed.Y, deltaTime),
		dampenAngle(sourceAngles.Z, goalAngles.Z, angularSpeed.Z, deltaTime)
	)
end

local function clampedAngles(angles: Vector3, lowerBounds: Vector3, upperBounds: Vector3)
	return CFrame.Angles(
		math.clamp(angles.X, lowerBounds.X, upperBounds.X),
		math.clamp(angles.Y, lowerBounds.Y, upperBounds.Y),
		math.clamp(angles.Z, lowerBounds.Z, upperBounds.Z)
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
	self.LookAngularSpeed = math.rad(600)

	-- Speed & bounds for rotating the root
	self.RootAngularSpeed = Vector3.new(80, 0) * math.rad(1)
	self.RootUpperBounds = Vector3.new(20, 30, 0) * math.rad(1)
	self.RootLowerBounds = Vector3.new(-55, -30, 0) * math.rad(1)

	-- Speed & bounds for rotating the waist
	self.WaistAngularSpeed = Vector3.new(100, 360) * math.rad(1)
	self.WaistUpperBounds = Vector3.new(30, 35, 0) * math.rad(1)
	self.WaistLowerBounds = Vector3.new(-55, -35, 0) * math.rad(1)

	-- Speed & bounds for rotating the neck
	self.NeckAngularSpeed = Vector3.new(200, 560) * math.rad(1)
	self.NeckUpperBounds = Vector3.new(25, 45, 0) * math.rad(1)
	self.NeckLowerBounds = Vector3.new(-35, -45, 0) * math.rad(1)

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
				lookPart.CFrame = CFrame.fromMatrix(
					Vector3.new(lookCFrame.X, math.max(lookCFrame.Y, workspace.FallenPartsDestroyHeight + lookPart.Size.Y / 2 + 2), lookCFrame.Z),
					lookCFrame.XVector,
					lookCFrame.YVector,
					lookCFrame.ZVector
				)
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

		-- Keep track of whether or not we want to perform look so we can zero out angles (instead of setting them)
		local shouldPerformLook = instance:GetAttribute("LookInAir") or humanoid:GetState() == Enum.HumanoidStateType.Running

		-- Root joint angles
		local lowerTorso: BasePart? = instance:FindFirstChild("LowerTorso")
		local root: Motor6D? = lowerTorso and lowerTorso:FindFirstChild("Root")
		if root then
			self._rootAngles = dampenAngles(
				self._rootAngles,
				if shouldPerformLook then
					Vector3.new(
						calculateJointAngle(-upVector, lowerTorso.Position, lookPosition),
						calculateJointAngle(rightVector, lowerTorso.Position, lookPosition),
						0
					)
				else Vector3.zero,
				self.RootAngularSpeed,
				deltaTime
			)

			local rootTransform = clampedAngles(self._rootAngles, self.RootLowerBounds, self.RootUpperBounds)
			root.Transform *= rootTransform
			root.C0 = rootC0 * rootTransform:Inverse()
		end

		-- Waist joint angles
		local upperTorso: BasePart? = instance:FindFirstChild("UpperTorso")
		local waist: Motor6D? = upperTorso and upperTorso:FindFirstChild("Waist")
		if waist then
			self._waistAngles = dampenAngles(
				self._waistAngles,
				if shouldPerformLook then
					Vector3.new(
						calculateJointAngle(-upVector, upperTorso.Position, lookPosition),
						calculateJointAngle(rightVector, upperTorso.Position, lookPosition),
						0
					)
				else Vector3.zero,
				self.WaistAngularSpeed,
				deltaTime
			)

			waist.Transform *= clampedAngles(self._waistAngles, self.WaistLowerBounds, self.WaistUpperBounds)
		end

		-- Neck joint angles
		local head: BasePart? = instance:FindFirstChild("Head")
		local neck: Motor6D? = head and head:FindFirstChild("Neck")
		if neck then
			self._neckAngles = dampenAngles(
				self._neckAngles,
				if shouldPerformLook then
					Vector3.new(
						calculateJointAngle(-upVector, head.Position, lookPosition),
						calculateJointAngle(rightVector, head.Position, lookPosition),
						0
					)
				else Vector3.zero,
				self.NeckAngularSpeed,
				deltaTime
			)

			neck.Transform *= clampedAngles(self._neckAngles, self.NeckLowerBounds, self.NeckUpperBounds)
		end

		if isLocalPlayer then
			local faceCursor = instance:GetAttribute("FaceCursorInAir") or humanoid:GetState() == Enum.HumanoidStateType.Running

			-- Y rotation
			local x, angle, z = cframe:ToOrientation()
			angle = dampenAngle(
				angle,
				if faceCursor then
					math.atan2(lookPosition.X - cframe.X, lookPosition.Z - cframe.Z) + math.rad(180)
				else angle,
				self.LookAngularSpeed,
				deltaTime
			)

			local newOrientation = CFrame.fromOrientation(x, angle, z)
			humanoid.AutoRotate = instance:GetAttribute("AutoRotate")
			rootPart:PivotTo(CFrame.fromMatrix(cframe.Position, newOrientation.XVector, newOrientation.YVector, newOrientation.ZVector))
		end
	end)

	return self
end

function CameraLook:Destroy()
	self._trove:Clean()
end

return CameraLook