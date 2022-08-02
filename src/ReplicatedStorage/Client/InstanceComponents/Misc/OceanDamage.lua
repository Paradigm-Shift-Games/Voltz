local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local OceanDamageConfig = require(ReplicatedStorage.Common.Config.OceanDamage)
local Trove = require(ReplicatedStorage.Packages.Trove)

local OceanDamage = {}
OceanDamage.__index = OceanDamage

function OceanDamage.new(character: Model)
	local humanoid = character:WaitForChild("Humanoid")
	print("Initializing OceanDamage!")

	local self = setmetatable({}, OceanDamage)

	self._trove = Trove.new()
	self._trove:Connect(RunService.Heartbeat, function(delta)
		if character.HumanoidRootPart.Position.Y > OceanDamageConfig.height then return end
		humanoid:TakeDamage(delta * OceanDamageConfig.damage)
	end)

	return self
end

function OceanDamage:Destroy()
	self._trove:Clean()
end

return OceanDamage