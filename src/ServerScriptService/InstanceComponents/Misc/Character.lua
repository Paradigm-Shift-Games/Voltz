local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

local Character = {}
Character.__index = Character

function Character.new(instance: Instance)
	local self = setmetatable({}, Character)

	self.Instance = instance
	self._trove = Trove.new()

	-- Add CameraLook tag to the character
	CollectionService:AddTag(instance, "CameraLook")

	return self
end

function Character:Destroy()
	self._trove:Clean()
end

return Character