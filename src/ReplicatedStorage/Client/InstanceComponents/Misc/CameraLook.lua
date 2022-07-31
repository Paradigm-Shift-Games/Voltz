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

	-- Speed for rotating the waist
	self.WaistPitchSpeed = math.rad(100)
	self.WaistYawSpeed = math.rad(360)

	-- Speed for rotating the neck
	self.NeckPitchSpeed = math.rad(200)
	self.NeckYawSpeed = math.rad(560)

	-- Grab base C0 for root part (TODO: Clean this up)
	local lowerTorso: BasePart = instance:WaitForChild("LowerTorso")
	local root: Motor6D = lowerTorso and lowerTorso:WaitForChild("Root")
	local rootC0 = root.C0

	-- Reset joint angles
	self._rootPitch = 0
	self._rootYaw = 0
	self._waistPitch = 0
	self._waistYaw = 0
	self._neckPitch = 0
	self._neckYaw = 0

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
			self._rootPitch = dampenAngle(self._rootPitch, calculateJointAngle(-upVector, lowerTorso.Position, lookPosition), self.RootPitchSpeed, deltaTime)
			self._rootYaw = dampenAngle(self._rootYaw, calculateJointAngle(rightVector, lowerTorso.Position, lookPosition), self.RootYawSpeed, deltaTime)
			local rootCFrame = CFrame.Angles(
				math.clamp(self._rootPitch, math.rad(-55), math.rad(20)),
				math.clamp(self._rootYaw, math.rad(-30), math.rad(30)),
				0
			)

			root.Transform *= rootCFrame
			root.C0 = rootC0 * rootCFrame:Inverse()
		end

		-- Waist joint angles
		local upperTorso: BasePart? = instance:FindFirstChild("UpperTorso")
		local waist: Motor6D? = upperTorso and upperTorso:FindFirstChild("Waist")
		if waist then
			self._waistPitch = dampenAngle(self._waistPitch, calculateJointAngle(-upVector, upperTorso.Position, lookPosition), self.WaistPitchSpeed, deltaTime)
			self._waistYaw = dampenAngle(self._waistYaw, calculateJointAngle(rightVector, upperTorso.Position, lookPosition), self.WaistYawSpeed, deltaTime)
			waist.Transform *= CFrame.Angles(
				math.clamp(self._waistPitch, math.rad(-55), math.rad(30)),
				math.clamp(self._waistYaw, math.rad(-35), math.rad(35)),
				0
			)
		end

		-- Neck joint angles
		local head: BasePart? = instance:FindFirstChild("Head")
		local neck: Motor6D? = head and head:FindFirstChild("Neck")
		if neck then
			self._neckPitch = dampenAngle(self._neckPitch, calculateJointAngle(-upVector, head.Position, lookPosition), self.NeckPitchSpeed, deltaTime)
			self._neckYaw = dampenAngle(self._neckYaw, calculateJointAngle(rightVector, head.Position, lookPosition), self.NeckYawSpeed, deltaTime)
			neck.Transform *= CFrame.Angles(
				math.clamp(self._neckPitch, math.rad(-35), math.rad(25)),
				math.clamp(self._neckYaw, math.rad(-45), math.rad(45)),
				0
			)
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