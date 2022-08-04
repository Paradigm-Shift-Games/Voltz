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

	self._comm = serverComm
	self._trove = Trove.new()
	self._trove:Add(self._comm)
	self._owner = Players:GetPlayerFromCharacter(character)
	self.Instance = character

	self._trove:Connect(character.AncestryChanged, function()
		self._owner = Players:GetPlayerFromCharacter(character.Parent)
	end)

	serverComm:WrapMethod(self, "StartSprinting")
	serverComm:WrapMethod(self, "StopSprinting")

	return self
end

function Sprint:Destroy()
	self._trove:Clean()
end

function Sprint:IsOwner(player: Player?)
	return player == nil or player == self._owner
end

function Sprint:StartSprinting(player: Player?)
	if not self:IsOwner(player) then return end
	local humanoid = self.Instance:FindFirstChildWhichIsA("Humanoid")
	if humanoid then humanoid.WalkSpeed = WalkSpeedConfig.Sprint end
end

function Sprint:StopSprinting(player: Player?)
	if not self:IsOwner(player) then return end
	local humanoid = self.Instance:FindFirstChildWhichIsA("Humanoid")
	if humanoid then humanoid.WalkSpeed = WalkSpeedConfig.Base end
end

return Sprint
