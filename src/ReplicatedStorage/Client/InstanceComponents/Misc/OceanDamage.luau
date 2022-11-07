local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local OceanDamageConfig = require(ReplicatedStorage.Common.Config.OceanDamage)
local Trove = require(ReplicatedStorage.Packages.Trove)

local OceanDamage = {}
OceanDamage.__index = OceanDamage

function OceanDamage.new(character: Model)
	local self = setmetatable({}, OceanDamage)

	self._humanoid = character:WaitForChild("Humanoid")
	self._trove = Trove.new()
	self._trove:Connect(RunService.Heartbeat, function(delta)
		local rootPart = self._humanoid.RootPart
		if not rootPart then return end

		if rootPart.Position.Y > OceanDamageConfig.Height then return end
		self._humanoid:TakeDamage(delta * OceanDamageConfig.Damage)
	end)

	return self
end

function OceanDamage:Destroy()
	self._trove:Clean()
end

return OceanDamage
