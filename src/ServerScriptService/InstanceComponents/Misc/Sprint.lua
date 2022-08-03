local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Comm = require(ReplicatedStorage.Packages.Comm)
local WalkSpeedConfig = require(ReplicatedStorage.Common.Config.WalkSpeed)

local Sprint = {}
Sprint.__index = Sprint

function Sprint.new(character: Model)
	local serverComm = Comm.ServerComm.new(character, "Sprint")
	local self = setmetatable({}, Sprint)

	self._character = character
	self._comm = serverComm
	self._trove = Trove.new()
	self._trove:Add(self._comm)

	self._owner = Players:GetPlayerFromCharacter(character.Parent)
	character.AncestryChanged:Connect(function()
		self._owner = Players:GetPlayerFromCharacter(character.Parent)
	end)

	self._startSprinting = serverComm:WrapMethod(self, "StartSprinting")
	self._stopSprinting = serverComm:WrapMethod(self, "StopSprinting")

	return self
end

function Sprint:Destroy()
	self._trove:Clean()
end

function Sprint:IsOwner(player: Player?)
	return player == self._owner
end

function Sprint:StartSprinting(player: Player?)
	if not self:IsOwner(player) then return end
	local humanoid = self._character:FindFirstChildWhichIsA("Humanoid")
	humanoid.WalkSpeed = WalkSpeedConfig.Sprint
end

function Sprint:StopSprinting(player: Player?)
	if not self:IsOwner(player) then return end
	local humanoid = self._character:FindFirstChildWhichIsA("Humanoid")
	humanoid.WalkSpeed = WalkSpeedConfig.Base
end

return Sprint