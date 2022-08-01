local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gun = require(ReplicatedStorage.Client.Tool.Gun)

local AssaultRifle = {}
AssaultRifle.__index = AssaultRifle
setmetatable(AssaultRifle, Gun)

function AssaultRifle.new(instance: Tool)
	local self = Gun.new(instance)
	setmetatable(self, AssaultRifle)
	return self
end

function AssaultRifle:Destroy()

end

return AssaultRifle