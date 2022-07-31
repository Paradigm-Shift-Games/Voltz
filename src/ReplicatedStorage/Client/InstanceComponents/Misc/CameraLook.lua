local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

local CameraLook = {}
CameraLook.__index = CameraLook

function CameraLook.new(instance: Instance)
	local self = setmetatable({}, CameraLook)

	self.Instance = instance
	self._trove = Trove.new()

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local rootPart = humanoid.RootPart

	local player = Players:GetPlayerFromCharacter(instance)
	local mouse = player:GetMouse()
	self._trove:Add(RunService.Stepped:Connect(function()
		local lookPosition = mouse.Hit.Position

		-- Waist
		local upperTorso: BasePart? = instance:FindFirstChild("UpperTorso")
		local waist: Motor6D? = upperTorso and upperTorso:FindFirstChild("Waist")
		if waist then
			waist.Transform = CFrame.new(math.rad(0), 0, 0)
		end

		-- Y rotation
		local cframe = rootPart:GetPivot()
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