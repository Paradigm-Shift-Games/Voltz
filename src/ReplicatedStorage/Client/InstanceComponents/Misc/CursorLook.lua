local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local CursorLookConfig = require(ReplicatedStorage.Common.Config.CursorLook)

local CursorLook = {}
CursorLook.__index = CursorLook

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

function CursorLook.new(instance: Instance)
	local self = setmetatable({}, CursorLook)

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
		-- Determine if the humanoid is on the ground (running)
		local isOnGround = humanoid:GetState() == Enum.HumanoidStateType.Running

		-- Whether or not we want the character to look at their cursor
		local shouldPerformLook = if isOnGround then instance:GetAttribute("LookOnGround") else instance:GetAttribute("LookInAir")

		-- Whether or not we want the character to face the cursor
		local shouldFaceCursor = if isOnGround then instance:GetAttribute("FaceCursorOnGround") else instance:GetAttribute("FaceCursorInAir")

		-- Whether or not the character should auto rotate
		local shouldAutoRotate = if isOnGround then instance:GetAttribute("AutoRotateOnGround") else instance:GetAttribute("AutoRotateInAir")

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
				CursorLookConfig.RootAngularSpeed,
				deltaTime
			)

			local rootTransform = clampedAngles(self._rootAngles, CursorLookConfig.RootLowerBounds, CursorLookConfig.RootUpperBounds)
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
				CursorLookConfig.WaistAngularSpeed,
				deltaTime
			)

			waist.Transform *= clampedAngles(self._waistAngles, CursorLookConfig.WaistLowerBounds, CursorLookConfig.WaistUpperBounds)
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
				CursorLookConfig.NeckAngularSpeed,
				deltaTime
			)

			neck.Transform *= clampedAngles(self._neckAngles, CursorLookConfig.NeckLowerBounds, CursorLookConfig.NeckUpperBounds)
		end

		if isLocalPlayer then
			-- Y rotation
			local x, angle, z = cframe:ToOrientation()
			angle = dampenAngle(
				angle,
				if shouldFaceCursor then
					math.atan2(lookPosition.X - cframe.X, lookPosition.Z - cframe.Z) + math.rad(180)
				else angle,
				CursorLookConfig.LookAngularSpeed,
				deltaTime
			)

			local newOrientation = CFrame.fromOrientation(x, angle, z)
			humanoid.AutoRotate = shouldAutoRotate
			rootPart:PivotTo(CFrame.fromMatrix(cframe.Position, newOrientation.XVector, newOrientation.YVector, newOrientation.ZVector))
		end
	end)

	return self
end

function CursorLook:Destroy()
	self._trove:Clean()
end

return CursorLook