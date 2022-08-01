local PlayerService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Common.Config.Fall)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)

local FallDamage = {}
FallDamage.__index = FallDamage

function FallDamage:_detectFallHeight(character: Model, humanoid: Humanoid, signal: Signal)
    local initialHeight = nil

    humanoid.FreeFalling:Connect(function(active)
        if active then
            initialHeight = character.HumanoidRootPart.Position.Y
        else
			signal:Fire(initialHeight - character.HumanoidRootPart.Position.Y)
        end
    end)
end

function FallDamage:_updateHealth(fallHeight, humanoid: Humanoid)
    if fallHeight < Config.threshold then return else
        local damage = (fallHeight - Config.threshold) * Config.scale
        humanoid.Health -= damage
        return damage
    end
end

function FallDamage.new(character: Model)
	local self = setmetatable({}, FallDamage)
	
    self._character = character
    self._humanoid = self._character:WaitForChild("Humanoid")
    self._trove = Trove.new()
    self._fallSignal = self._trove:Construct(Signal)
    self.Health = self._humanoid.Health

    self:_detectFallHeight(self._character, self._humanoid, self._fallSignal)

    self._trove:Connect(self._fallSignal, function(fallHeight) self:_updateHealth(fallHeight, self._humanoid) end)

    return self
end

function FallDamage:Destroy()
    self._trove:Clean()
end

return FallDamage