local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

local Character = {}
Character.__index = Character

function Character.new(instance: Instance)
	local self = setmetatable({}, Character)

	self.Instance = instance
	self._trove = Trove.new()

	-- Apply defaults when on the ground
	instance:SetAttribute("AutoRotateOnGround", false)
	instance:SetAttribute("FaceCursorOnGround", true)
	instance:SetAttribute("LookOnGround", true)

	-- Apply defaults when in the air
	instance:SetAttribute("AutoRotateInAir", true)
	instance:SetAttribute("FaceCursorInAir", false)
	instance:SetAttribute("LookInAir", false)

	-- Add tags to the character
	CollectionService:AddTag(instance, "CursorLook")
	CollectionService:AddTag(instance, "FallDamage")
	CollectionService:AddTag(instance, "OceanDamage")
	CollectionService:AddTag(instance, "Sprint")

	-- TODO: Use actual jetpack model
	-- Add Jetpack tag to the character's root part
	local rootPart = instance.PrimaryPart
	while not rootPart do
		rootPart = instance.PrimaryPart
		instance.ChildAdded:Wait() -- NOTE: A property signal is not used to support streaming enabled
	end

	-- Apply defaults for jetpack
	rootPart:SetAttribute("Fuel", 1)
	rootPart:SetAttribute("Capacity", 100)
	rootPart:SetAttribute("FillRate", 30)
	rootPart:SetAttribute("BurnRate", 65)

	-- Apply defaults for jetpack thrust
	rootPart:SetAttribute("ThrustAcceleration", 140)
	rootPart:SetAttribute("MaxThrustSpeed", 22)

	-- Add Jetpack tag to the character root (TODO: Use jetpack model)
	CollectionService:AddTag(rootPart, "Jetpack")

	return self
end

function Character:Destroy()
	self._trove:Clean()
end

return Character