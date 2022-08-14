---@diagnostic disable-next-line: undefined-global
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ObserverConfig = require(ReplicatedStorage.Common.Config.Structures.Observer)
local Range = ObserverConfig.Range

local Observer = {}
Observer.__index = Observer

function Observer.new(instance)
	local self = setmetatable({}, Observer)
	self.Instance = instance

    RunService.Heartbeat:Connect(function()
        if self.Instance == nil then return end
        for _,v in pairs(Players:GetPlayers()) do
            if not v.Character then return end
            local distanceBetweenParts = (v.Character.HumanoidRootPart.Position - self.Instance.PrimaryPart.Position).Magnitude
            if distanceBetweenParts < Range then
                self.Instance.PrimaryPart.Color = Color3.fromRGB(0,255,0)
            else
                self.Instance.PrimaryPart.Color = Color3.fromRGB(255,0,0)
            end
        end
    end)

	return self
end

function Observer:Destroy()

end

return Observer