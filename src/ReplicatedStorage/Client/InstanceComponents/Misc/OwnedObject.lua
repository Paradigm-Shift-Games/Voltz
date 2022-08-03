local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Comm = require(ReplicatedStorage.Packages.Comm)

--[=[
	@class OwnedObject
]=]
local OwnedObject = {}
OwnedObject.__index = OwnedObject

function OwnedObject.new(instance: Instance)
	local clientComm = Comm.ClientComm.new(instance, false, "OwnedObject")
	local self = setmetatable({}, OwnedObject)
	self.Instance = instance
	self._trove = Trove.new()

	-- Add comm to trove
	self._trove:Add(clientComm)

	-- Get owner ID property
	self._ownerIdProp = clientComm:GetProperty("OwnerId")

	-- When the owner ID property is uppdated
	self._ownerIdProp:Observe(function(owner)
		-- Update the owner
		self:_setOwner(owner)
	end)

	return self
end

function OwnedObject:_getUserId(user: (Player | number)?): number
	return assert(
		if type(user) == "number" then
			user
		elseif
			typeof(user) == "Instance" and user:IsA("Player") then user.UserId
		else nil,
		"Argument #1 for OwnedObject:IsOwner() must be a Player instance or UserId."
	)
end

--[=[
	@client
	Returns whether or not the local player owns this object.

	@return boolean
]=]
function OwnedObject:IsOwner()
	return self._ownerId == Players.LocalPlayer.UserId
end

function OwnedObject:_setOwner(user: (Player | number)?)
	local ownerId = if user == nil then nil else self:_getUserId(user)

	-- Update ownership properties
	self._ownerId = ownerId
end

function OwnedObject:GetOwner(): Player?
	return self._ownerId and Players:GetPlayerByUserId(self._ownerId)
end

function OwnedObject:GetOwnerId(): number?
	return self._ownerId
end

function OwnedObject:Destroy()
	self._trove:Clean()
end

return OwnedObject