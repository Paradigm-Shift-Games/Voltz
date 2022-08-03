local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local BinderService = require(ServerScriptService.Services.BinderService)

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

	-- Add CameraLook tag to the character
	CollectionService:AddTag(instance, "OwnedObject")
	CollectionService:AddTag(instance, "CursorLook")
	CollectionService:AddTag(instance, "FallDamage")
	CollectionService:AddTag(instance, "OceanDamage")

	-- Get the OwnedObject component
	local OwnedObject = BinderService:Get("OwnedObject")
	local ownedObject = OwnedObject:Get(instance)

	-- Apply automatic ownership
	ownedObject:SetAutomaticOwnership(true)

	return self
end

function Character:Destroy()
	self._trove:Clean()
end

return Character