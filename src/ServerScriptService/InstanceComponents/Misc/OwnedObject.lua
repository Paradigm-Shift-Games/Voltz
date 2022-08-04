local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Comm = require(ReplicatedStorage.Packages.Comm)

--[=[
	@class OwnedObject
]=]
local OwnedObject = {}
OwnedObject.__index = OwnedObject

function OwnedObject.new(instance: Instance, owner: (Player | number)?)
	local serverComm = Comm.ServerComm.new(instance, "OwnedObject")
	local self = setmetatable({}, OwnedObject)
	self.Instance = instance
	self._trove = Trove.new()

	-- Add comm to trove
	self._trove:Add(serverComm)

	-- Create owner ID property
	self._ownerIdProp = serverComm:CreateProperty("OwnerId", nil)

	-- Update the owner
	self:SetOwner(owner)

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
	@server
	Tracks the ancestry of the bound instance, treating the top-most ancestor under workspace as the character of a player.
	Automatically assigns the ownership of this object.
]=]
function OwnedObject:SetAutomaticOwnership(state: boolean)
	if state and not self._ownershipTracking then
		local function updateOwnershipAuto()
			local character = self.Instance
			local owner: Player? = nil

			-- Traverse up ancestry to find the character & owner player
			repeat
				owner = Players:GetPlayerFromCharacter(character)
				if not owner then
					character = character.Parent
				end
			until owner or not character:IsDescendantOf(workspace)

			-- If the owner differs, update it
			if self:GetOwner() ~= owner then
				self:SetOwner(owner)
			end
		end

		-- Update the owner once immediately
		updateOwnershipAuto()

		-- When ancestry changes, update the owner
		self._ownershipTracking = self.Instance.AncestryChanged:Connect(updateOwnershipAuto)
	elseif not state and self._ownershipTracking then
		self._ownershipTracking:Disconnect()
		self._ownershipTracking = nil
	end
end

--[=[
	@server
	Returns whether or not the given user owns the object.
	If nil is passed (server-sided), will return true.

	@param user (Player | number)? -- The `Player` or their `UserId`, or `nil` if server-sided.
	@return boolean
]=]
function OwnedObject:IsOwner(user: (Player | number)?)
	return user == nil or self._ownerId == self:_getUserId(user)
end

--[=[
	@server
	Updates the owner of the instance.

	@param user (Player | number)? -- The `Player` or their `UserId`
]=]
function OwnedObject:SetOwner(user: (Player | number)?)
	local ownerId = if user == nil then nil else self:_getUserId(user)

	-- Update ownership properties
	self._ownerId = ownerId
	self._ownerIdProp:Set(ownerId)
end

--[=[
	@return Player? -- The owner Player, if they are in the game.
]=]
function OwnedObject:GetOwner(): Player?
	return self._ownerId and Players:GetPlayerByUserId(self._ownerId)
end

--[=[
	@return number? -- The owner's ID.
]=]
function OwnedObject:GetOwnerId(): number?
	return self._ownerId
end

--[=[
	Destroys the component.
]=]
function OwnedObject:Destroy()
	if self._ownershipTracking then
		self._ownershipTracking:Disconnect()
		self._ownershipTracking = nil
	end
	self._trove:Clean()
end

return OwnedObject