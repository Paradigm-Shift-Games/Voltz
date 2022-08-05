local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Comm = require(ReplicatedStorage.Packages.Comm)
local CursorLookConfig = require(ReplicatedStorage.Common.Config.CursorLook)

local CursorLook = {}
CursorLook.__index = CursorLook

local function calculateJointAngle(lookVector, sourcePosition, targetPosition)
	return math.asin((sourcePosition - targetPosition):Dot(lookVector)/(sourcePosition - targetPosition).Magnitude)
end

local function calculateAngleDifference(angleA, angleB)
	local angleDiff = angleA % math.rad(360) - angleB % math.rad(360)
	if math.abs(angleDiff) > math.rad(180) then
		local dividend = math.sign(angleDiff) * math.rad(180)
		angleDiff = angleDiff%dividend - dividend
	end
	return angleDiff
end

local easingStyle = Enum.EasingStyle.Quint
local easingDirection = Enum.EasingDirection.In
local function dampenAngle(sourceAngle: number, goalAngle: number, angularSpeed: number, deltaTime: number)
	local angleDiff = calculateAngleDifference(goalAngle, sourceAngle)
	return sourceAngle + math.sign(angleDiff) * TweenService:GetValue(
		math.clamp(
			math.min(1, math.abs(angleDiff / deltaTime) / angularSpeed),
			0,
			1
		),
		easingStyle,
		easingDirection
	) * angularSpeed * deltaTime
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
	self._comm = self._trove:Construct(Comm.ClientComm, instance, false, "Cursor")

	-- Wait for Humanoid to be added
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")
	while not humanoid do
		humanoid = instance:FindFirstChildWhichIsA("Humanoid")
		instance.ChildAdded:Wait()
	end

	-- Grab base C0 for root part (TODO: Clean this up)
	local lowerTorso: BasePart = instance:WaitForChild("LowerTorso")
	local root: Motor6D = lowerTorso and lowerTorso:WaitForChild("Root")
	local rootC0 = root.C0

	-- Reset joint angles
	self._rootAngles = Vector3.zero
	self._waistAngles = Vector3.zero
	self._neckAngles = Vector3.zero
	self._rightShoulderAngles = Vector3.zero

	-- Create hip attachment
	local hipAttachment = self._trove:Construct(Instance, "Attachment")
	hipAttachment.Name = "HipAttachment"
	hipAttachment.Position = CursorLookConfig.HipOffset

	-- Create chest attachment
	local chestAttachment = self._trove:Construct(Instance, "Attachment")
	chestAttachment.Name = "ChestAttachment"
	chestAttachment.Position = CursorLookConfig.ChestOffset

	-- Create eye attachment
	local eyeAttachment = self._trove:Construct(Instance, "Attachment")
	eyeAttachment.Position = CursorLookConfig.EyeOffset
	eyeAttachment.Name = "EyeAttachment"

	-- Create tool attachment
	local toolAttachment = self._trove:Construct(Instance, "Attachment")
	toolAttachment.Position = CursorLookConfig.ToolOffset
	toolAttachment.Name = "ToolAttachment"

	-- Get shared cursor property
	local cursorProp = self._comm:GetProperty("Cursor")

	-- Update joint angles
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

		-- Find the player's tool and determine if it is held
		local tool = instance:FindFirstChildWhichIsA("Tool")
		local toolHandle = tool and tool:FindFirstChild("Handle")

		-- Whether or not the player's arm should aim at their mouse
		local shouldRotateArm = toolHandle and if isOnGround then instance:GetAttribute("AimToolOnGround") else instance:GetAttribute("AimToolInAir")

		-- Retrieve player root part
		local rootPart = humanoid.RootPart
		if not rootPart then
			return
		end

		-- Get root CFrame & vectors
		local cframe = rootPart:GetPivot()

		local upVector = cframe.UpVector
		local rightVector = cframe.RightVector
		local lookVector = cframe.LookVector

		-- Locate mouse target part
		local lookPart: BasePart = cursorProp:Get()
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
			hipAttachment.Parent = lowerTorso
			local hipPosition = hipAttachment.WorldPosition
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
			chestAttachment.Parent = upperTorso
			local chestPosition = chestAttachment.WorldPosition
			self._waistAngles = dampenAngles(
				self._waistAngles,
				if shouldPerformLook then
					Vector3.new(
						calculateJointAngle(-upVector, chestPosition, lookPosition),
						calculateJointAngle(rightVector, chestPosition, lookPosition),
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
			eyeAttachment.Parent = head
			local eyePosition = eyeAttachment.WorldPosition
			self._neckAngles = dampenAngles(
				self._neckAngles,
				if shouldPerformLook then
					Vector3.new(
						calculateJointAngle(-upVector, eyePosition, lookPosition),
						calculateJointAngle(rightVector, eyePosition, lookPosition),
						0
					)
				else Vector3.zero,
				CursorLookConfig.NeckAngularSpeed,
				deltaTime
			)

			neck.Transform *= clampedAngles(self._neckAngles, CursorLookConfig.NeckLowerBounds, CursorLookConfig.NeckUpperBounds)
		end

		-- Right shoulder joint angles
		local rightUpperArm: BasePart? = instance:FindFirstChild("RightUpperArm")
		local rightShoulder: Motor6D? = rightUpperArm and rightUpperArm:FindFirstChild("RightShoulder")
		if rightShoulder then
			toolAttachment.Parent = rightUpperArm
			local endPointAttachment = toolAttachment
			local toolPosition = endPointAttachment.WorldPosition
			self._rightShoulderAngles = dampenAngles(
				self._rightShoulderAngles,
				if shouldRotateArm then
					Vector3.new( -- Note: The angles are a bit weird for this joint, the Y and Z values are flipped
						calculateJointAngle(-if upperTorso then upperTorso.CFrame.UpVector else upVector, toolPosition, lookPosition), -- Pitch
						-calculateJointAngle(-if upperTorso then upperTorso.CFrame.RightVector else rightVector, toolPosition, lookPosition), -- Roll
						-calculateJointAngle(if upperTorso then upperTorso.CFrame.RightVector else rightVector, toolPosition, lookPosition) -- Yaw
					)
				else Vector3.zero,
				CursorLookConfig.RightShoulderAngularSpeed,
				deltaTime
			)

			rightShoulder.Transform *= clampedAngles(self._rightShoulderAngles, CursorLookConfig.RightShoulderLowerBounds, CursorLookConfig.RightShoulderUpperBounds)
		end

		if isLocalPlayer then
			-- Y rotation
			local x, characterAngle, z = cframe:ToOrientation()
			local cursorAngle = if shouldFaceCursor then math.atan2(lookPosition.X - cframe.X, lookPosition.Z - cframe.Z) + math.rad(180) else characterAngle

			local faceCursorThreshold = instance:GetAttribute("FaceCursorThreshold")
			local isOutsideFaceCursorThreshold = false
			if shouldFaceCursor and faceCursorThreshold and faceCursorThreshold < 360 then
				local angleDifference = math.deg(calculateAngleDifference(cursorAngle, characterAngle))
				isOutsideFaceCursorThreshold = math.abs(angleDifference) >= faceCursorThreshold / 2

				if isOutsideFaceCursorThreshold then
					-- Calculate angle within range of threshold
					cursorAngle = characterAngle + math.rad(math.sign(angleDifference) * (math.abs(angleDifference) - (faceCursorThreshold / 2)))
				end
			end

			characterAngle = dampenAngle(
				characterAngle,
				if shouldFaceCursor and isOutsideFaceCursorThreshold then cursorAngle else characterAngle,
				CursorLookConfig.LookAngularSpeed,
				deltaTime
			)

			local newOrientation = CFrame.fromOrientation(x, characterAngle, z)
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