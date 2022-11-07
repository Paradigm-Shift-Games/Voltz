local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gun = require(ReplicatedStorage.Client.Tool.Gun)
local AssaultRifleConfig = require(ReplicatedStorage.Common.Config.Guns.HighPowerPhotonLancer)

local HighPowerPhotonLancer = setmetatable({}, Gun)
HighPowerPhotonLancer.__index = HighPowerPhotonLancer
HighPowerPhotonLancer.Config = AssaultRifleConfig

function HighPowerPhotonLancer.new(instance: Tool)
	local self = setmetatable(Gun.new(instance), HighPowerPhotonLancer)
	return self
end

function HighPowerPhotonLancer:Destroy()

end

return HighPowerPhotonLancer