local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FallDamageConfig = require(ReplicatedStorage.Common.Config.FallDamage)
local Trove = require(ReplicatedStorage.Packages.Trove)

local FallDamage = {}
FallDamage.__index = FallDamage

function FallDamage:_trackCharacterFall(character: Model, humanoid: Humanoid)
	local initialHeight = nil
	local fallHeight = nil

	self._trove:Connect(humanoid.FreeFalling, function(active)
		if active then
			initialHeight = character.HumanoidRootPart.Position.Y
		else
			fallHeight = initialHeight - character.HumanoidRootPart.Position.Y
			if fallHeight < FallDamageConfig.Threshold then return end

			local damage = (fallHeight - FallDamageConfig.Threshold) * FallDamageConfig.Scale
			humanoid:TakeDamage(damage)
		end
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