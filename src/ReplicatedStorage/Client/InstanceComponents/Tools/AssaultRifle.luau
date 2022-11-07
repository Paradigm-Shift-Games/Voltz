local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gun = require(ReplicatedStorage.Client.Tool.Gun)
local AssaultRifleConfig = require(ReplicatedStorage.Common.Config.Guns.AssaultRifle)

local AssaultRifle = setmetatable({}, Gun)
AssaultRifle.__index = AssaultRifle
AssaultRifle.Config = AssaultRifleConfig

function AssaultRifle.new(instance: Tool)
	local self = setmetatable(Gun.new(instance), AssaultRifle)
	return self
end

function AssaultRifle:Destroy()

end

return AssaultRifle