local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

local Player = {}
Player.__index = Player

function Player.new(instance: Instance)
	local self = setmetatable({}, Player)

	self.Instance = instance
	self._trove = Trove.new()

	instance.CharacterAdded:Connect(function(character)
		CollectionService:AddTag(character, "Character")
	end)

	-- FIXME: Roblox doesn't destroy player instance by default
	self._trove:Add(instance)
	instance.AncestryChanged:Connect(function()
		if not instance:IsDescendantOf(Players) then
			self:Destroy()
		end
	end)
	return self
end

function Player:Destroy()
	self._trove:Clean()
end

return Player