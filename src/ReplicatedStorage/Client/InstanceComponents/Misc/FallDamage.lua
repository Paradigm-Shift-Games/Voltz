local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FallDamageConfig = require(ReplicatedStorage.Common.Config.FallDamage)
local Trove = require(ReplicatedStorage.Packages.Trove)

local FallDamage = {}
FallDamage.__index = FallDamage

function FallDamage.new(character: Model)
	local self = setmetatable({}, FallDamage)

	self._humanoid = character:WaitForChild("Humanoid")
	self._trove = Trove.new()
	self._trove:Connect(self._humanoid.StateChanged, function(old, new)
		if not (old == Enum.HumanoidStateType.Freefall and new == Enum.HumanoidStateType.Landed) then return end

		local endVelocity = self._humanoid.RootPart.AssemblyLinearVelocity.Magnitude

		if endVelocity - FallDamageConfig.MaxVelocityThreshold < 0 then return end
		self._humanoid:TakeDamage((endVelocity - FallDamageConfig.MaxVelocityThreshold) * FallDamageConfig.DamageScale)
	end)

	return self
end

function FallDamage:Destroy()
	self._trove:Clean()
end

return FallDamage