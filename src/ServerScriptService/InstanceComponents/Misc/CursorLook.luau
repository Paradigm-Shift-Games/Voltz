local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Comm = require(ReplicatedStorage.Packages.Comm)

-- Create shared CursorObjects folder
local mouseFolder = Instance.new("Folder")
mouseFolder.Name = "CursorObjects"
mouseFolder.Parent = workspace

local CursorLook = {}
CursorLook.__index = CursorLook

function CursorLook.new(instance: Instance)
	local serverComm = Comm.ServerComm.new(instance, "Cursor")
	local self = setmetatable({}, CursorLook)

	self.Instance = instance
	self._trove = Trove.new()
	self._trove:Add(serverComm)

	-- Create shared Cursor property
	self._cursorProp = serverComm:CreateProperty("Cursor", nil)

	-- Create the mouse cursor
	self:CreateCursor()

	return self
end

function CursorLook:_constructThrustConstraint(mouseCursor: BasePart)
	-- Place an attachment into the part
	local attachment0 = Instance.new("Attachment")
	attachment0.Parent = mouseCursor

	-- Create a vector force to counteract gravity
	local vectorForce = Instance.new("VectorForce")
	vectorForce.Attachment0 = attachment0
	vectorForce.Force = Vector3.new(0, mouseCursor.AssemblyMass * workspace.Gravity, 0)
	vectorForce.ApplyAtCenterOfMass = true
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Parent = mouseCursor
end

function CursorLook:_constructCursorPart(): BasePart
	-- Create a part for the player's mouse target
	local mouseCursor = Instance.new("Part")
	mouseCursor.Name = "Cursor"

	-- Assign physical properties
	mouseCursor.Size = Vector3.new(1, 1, 1)
	mouseCursor.CanCollide = false
	mouseCursor.CanQuery = false
	mouseCursor.CanTouch = false
	mouseCursor.Locked = true

	-- Assign visual properties
	mouseCursor.Transparency = 1
	mouseCursor.Material = Enum.Material.Neon
	mouseCursor.Color = Color3.new(1, 0, 1)
	mouseCursor.Shape = Enum.PartType.Cylinder

	-- Create the jetpack thrust constraint
	self:_constructThrustConstraint(mouseCursor)

	return mouseCursor
end

function CursorLook:CreateCursor()
	local player = Players:GetPlayerFromCharacter(self.Instance)
	local mouseCursor = self:_constructCursorPart()

	-- Parent mouse target part, and give network ownership
	mouseCursor.Parent = mouseFolder
	mouseCursor:SetNetworkOwner(player)

	-- When the mouse target is destroyed, create a new mouse target
	mouseCursor.Destroying:Connect(function()
		self:CreateCursor()
	end)

	-- Update the mouse cursor
	self._mouseCursor = mouseCursor
	self._cursorProp:Set(mouseCursor)
end

function CursorLook:Destroy()
	-- Clean up mouse cursor part
	if self._mouseCursor then
		self._mouseCursor:Destroy()
	end

	-- Clean trove
	self._trove:Clean()
end

return CursorLook