local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FallDamageConfig = require(ReplicatedStorage.Common.Config.FallDamage)
local Trove = require(ReplicatedStorage.Packages.Trove)

local FallDamage = {}
FallDamage.__index = FallDamage

function FallDamage:_getDamage(velocity)
	local processedSpeed = velocity.Magnitude - FallDamageConfig.MaxSpeedThreshold

	return math.clamp(processedSpeed * FallDamageConfig.DamageScale, 0, math.huge)
end

function FallDamage.new(character: Model)
	local self = setmetatable({}, FallDamage)

	self._humanoid = character:WaitForChild("Humanoid")
	self._trove = Trove.new()
	self._trove:Connect(self._humanoid.StateChanged, function(old, new)
		if not (old == Enum.HumanoidStateType.Freefall and new == Enum.HumanoidStateType.Landed) then return end

		self._humanoid:TakeDamage(self:_getDamage(self._humanoid.RootPart.AssemblyLinearVelocity))
	end)

	return self
end

function FallDamage:Destroy()
	self._trove:Clean()
end

return FallDamage