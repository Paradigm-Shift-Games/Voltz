local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gun = require(ReplicatedStorage.Client.Tool.Gun)
local SMGConfig = require(ReplicatedStorage.Common.Config.Guns.SMG)

local SMG = setmetatable({}, Gun)
SMG.__index = SMG
SMG.Config = SMGConfig

function SMG.new(instance: Tool)
	local self = setmetatable(Gun.new(instance), SMG)
	return self
end

function SMG:Destroy()

end

return SMG