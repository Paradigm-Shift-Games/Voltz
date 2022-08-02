local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gun = require(ReplicatedStorage.Client.Tool.Gun)

local SMG = {}
SMG.__index = SMG
setmetatable(SMG, Gun)
SMG.Config = require(ReplicatedStorage.Common.Config.Guns.SMG)

function SMG.new(instance: Tool)
	local self = Gun.new(instance)
	setmetatable(self, SMG)
	return self
end

function SMG:Destroy()

end

return SMG