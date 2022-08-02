local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gun = require(ReplicatedStorage.Client.Tool.Gun)

local Shotgun = {}
Shotgun.__index = Shotgun
setmetatable(Shotgun, Gun)
Shotgun.Config = require(ReplicatedStorage.Common.Config.Guns.Shotgun)

function Shotgun.new(instance)
	local self = Gun.new(instance)
	setmetatable(self, Shotgun)
	return self
end

function Shotgun:Destroy()

end

return Shotgun