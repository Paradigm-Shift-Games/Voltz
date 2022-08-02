local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gun = require(ReplicatedStorage.Client.Tool.Gun)

local Shotgun = setmetatable({}, Gun)
Shotgun.__index = Shotgun
Shotgun.Config = require(ReplicatedStorage.Common.Config.Guns.Shotgun)

function Shotgun.new(instance: Tool)
	local self = setmetatable(Gun.new(instance), Shotgun)
	return self
end

function Shotgun:Destroy()

end

return Shotgun