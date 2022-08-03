local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FallDamageConfig = require(ReplicatedStorage.Common.Config.FallDamage)
local Trove = require(ReplicatedStorage.Packages.Trove)

local FallDamage = {}
FallDamage.__index = FallDamage

function FallDamage:_trackCharacterFall(character: Model, humanoid: Humanoid)
	local endVelocity = nil

	self._trove:Connect(humanoid.StateChanged, function(old, new)
		if not (old == Enum.HumanoidStateType.Freefall and new == Enum.HumanoidStateType.Landed) then return end

		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

		endVelocity = humanoidRootPart.AssemblyLinearVelocity.Magnitude
		humanoid:TakeDamage((endVelocity - FallDamageConfig.Threshold) * FallDamageConfig.Scale)
	end)
end

function FallDamage.new(character: Model)
	local humanoid = character:WaitForChild("Humanoid")

	local self = setmetatable({}, FallDamage)

	self._trove = Trove.new()
	self:_trackCharacterFall(character, humanoid)

	return self
end

function FallDamage:Destroy()
	self._trove:Clean()
end

return FallDamage