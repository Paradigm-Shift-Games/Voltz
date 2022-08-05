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
	instance:SetAttribute("AimToolOnGround", true)

	-- Apply defaults when in the air
	instance:SetAttribute("AutoRotateInAir", true)
	instance:SetAttribute("FaceCursorInAir", false)
	instance:SetAttribute("LookInAir", false)
	instance:SetAttribute("AimToolInAir", true)

	-- Degrees of freedom for FaceCursor to activate (0 fixes to cursor)
	instance:SetAttribute("FaceCursorThreshold", 65)

	-- Add CameraLook tag to the character
	CollectionService:AddTag(instance, "CursorLook")
	CollectionService:AddTag(instance, "FallDamage")
	CollectionService:AddTag(instance, "OceanDamage")

	return self
end

function Character:Destroy()
	self._trove:Clean()
end

return Character