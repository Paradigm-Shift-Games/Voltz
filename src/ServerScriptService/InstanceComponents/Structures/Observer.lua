local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Trove = require(ReplicatedStorage.Packages.Trove)

local ObserverConfig = require(ReplicatedStorage.Common.Config.Structures.Observer)

local Observer = {}
Observer.__index = Observer

function Observer:_isPlayerNearby()
	for _, player in Players:GetPlayers() do
		if not player.Character then continue end

		local distanceBetweenParts = (player.Character.HumanoidRootPart.Position - self.Instance.PrimaryPart.Position).Magnitude
		if distanceBetweenParts < ObserverConfig.Range then return true end
	end

	return false
end

function Observer.new(instance)
	local self = setmetatable({}, Observer)
	self.Instance = instance
	self._trove = Trove.new()

	self._trove:Connect(RunService.Heartbeat, function()
		self.Instance.PrimaryPart.Color = if self:_isPlayerNearby() then  Color3.fromRGB(0, 255, 0) else Color3.fromRGB(255, 0, 0)
	end)

	return self
end

function Observer:Destroy()
	self._trove:Clean()
end

return Observer