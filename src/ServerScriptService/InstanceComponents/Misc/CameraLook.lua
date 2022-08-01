local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Trove = require(ReplicatedStorage.Packages.Trove)

local CameraLook = {}
CameraLook.__index = CameraLook

function CameraLook.new(instance: Instance)
	local self = setmetatable({}, CameraLook)

	self.Instance = instance
	self._trove = Trove.new()

	local player = Players:GetPlayerFromCharacter(instance)

	-- Create a part for the player's mouse target
	local mouseTarget = Instance.new("Part")
	mouseTarget.Name = "MouseTarget"
	mouseTarget.Transparency = 1
	mouseTarget.Size = Vector3.new(1, 1, 1)
	mouseTarget.CanCollide = false
	mouseTarget.CanQuery = false
	mouseTarget.CanTouch = false

	mouseTarget.Material = Enum.Material.Neon
	mouseTarget.Color = Color3.new(1, 0, 1)
	mouseTarget.Shape = Enum.PartType.Ball

	-- Place an attachment into the part
	local attachment0 = Instance.new("Attachment")
	attachment0.Parent = mouseTarget

	-- Create a vector force to counteract gravity
	local vectorForce = Instance.new("VectorForce")
	vectorForce.Force = Vector3.new(0, mouseTarget.AssemblyMass * workspace.Gravity, 0)
	vectorForce.Attachment0 = attachment0
	vectorForce.ApplyAtCenterOfMass = true
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Parent = mouseTarget

	-- Parent mouse target part to character, and give network ownership
	mouseTarget.Parent = instance
	mouseTarget:SetNetworkOwner(player)

	-- Add mouse target part to trove
	self._trove:Add(mouseTarget)

	return self
end

function CameraLook:Destroy()
	self._trove:Clean()
end

return CameraLook