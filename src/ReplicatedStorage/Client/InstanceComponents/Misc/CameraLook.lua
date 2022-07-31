local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

local CameraLook = {}
CameraLook.__index = CameraLook

local function calculateJointAngle(sourcePosition, targetPosition)
	return math.asin((sourcePosition.Y - targetPosition.Y)/(sourcePosition - targetPosition).Magnitude)
end

function CameraLook.new(instance: Instance)
	local self = setmetatable({}, CameraLook)

	self.Instance = instance
	self._trove = Trove.new()

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local rootPart = humanoid.RootPart

	-- Grab base C0 for root part (TODO: Clean this up)
	local lowerTorso: BasePart? = instance:FindFirstChild("LowerTorso")
	local root: Motor6D? = lowerTorso and lowerTorso:FindFirstChild("Root")
	local rootC0 = root.C0

	local player = Players:GetPlayerFromCharacter(instance)
	local mouse = player:GetMouse()
	self._trove:Add(RunService.Stepped:Connect(function()
		local lookPosition = mouse.Hit.Position
		local cframe = rootPart:GetPivot()

		-- Root joint angles
		local lowerTorso: BasePart? = instance:FindFirstChild("LowerTorso")
		local root: Motor6D? = lowerTorso and lowerTorso:FindFirstChild("Root")
		if root then
			root.Transform *= CFrame.Angles(-calculateJointAngle(lowerTorso.Position, lookPosition), 0, 0)
			root.C0 = rootC0 * root.Transform:Inverse()
		end
		-- Waist joint angles
		local upperTorso: BasePart? = instance:FindFirstChild("UpperTorso")
		local waist: Motor6D? = upperTorso and upperTorso:FindFirstChild("Waist")
		if waist then
			waist.Transform *= CFrame.Angles(math.clamp(-calculateJointAngle(upperTorso.Position, lookPosition), math.rad(-55), math.rad(35)), 0, 0)
		end
		-- Neck joint angles
		local head: BasePart? = instance:FindFirstChild("Head")
		local neck: Motor6D? = head and head:FindFirstChild("Neck")
		if neck then
			neck.Transform *= CFrame.Angles(math.clamp(-calculateJointAngle(head.Position, lookPosition), math.rad(-15), math.rad(25)), 0, 0)
		end

		-- Y rotation
		local x, _, z = cframe:ToOrientation()

		local newOrientation = CFrame.fromOrientation(x, math.atan2(lookPosition.X - cframe.X, lookPosition.Z - cframe.Z) + math.rad(180), z)

		rootPart:PivotTo(CFrame.fromMatrix(cframe.Position, newOrientation.XVector, newOrientation.YVector, newOrientation.ZVector))
	end))

	return self
end

function CameraLook:Destroy()
	self._trove:Clean()
end

return CameraLook