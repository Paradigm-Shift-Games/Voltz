local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FallDamageConfig = require(ReplicatedStorage.Common.Config.FallDamage)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

local FallDamage = {}
FallDamage.__index = FallDamage

function FallDamage:_detectFallHeight(character: Model, humanoid: Humanoid)
    local initialHeight = nil

    self._trove:Connect(humanoid.FreeFalling:Connect(function(active)
        if active then
            initialHeight = character.HumanoidRootPart.Position.Y
        else
			self._fallSignal:Fire(initialHeight - character.HumanoidRootPart.Position.Y)
        end
    end))
end

function FallDamage:_updateHealth(fallHeight, humanoid: Humanoid)
    if fallHeight < FallDamageConfig.threshold then return end

    local damage = (fallHeight - FallDamageConfig.threshold) * FallDamageConfig.scale
    humanoid.Health -= damage
    return damage
end

function FallDamage.new(character: Model)
    local humanoid = character:WaitForChild("Humanoid")

    local self = setmetatable({}, FallDamage)

    self._trove = Trove.new()
    self._fallSignal = self._trove:Construct(Signal)
    self:_detectFallHeight(character, humanoid)
    self._trove:Connect(self._fallSignal, function(fallHeight) self:_updateHealth(fallHeight, humanoid) end)

    return self
end

function FallDamage:Destroy()
    self._trove:Clean()
end

return FallDamage