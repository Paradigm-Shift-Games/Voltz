local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ObserverConfig = require(ReplicatedStorage.Common.Config.Structures.Observer)

local Observer = {}
Observer.__index = Observer

function Observer.new(instance)
	local self = setmetatable({}, Observer)
	self.Instance = instance

    self._heartbeatConnection = RunService.Heartbeat:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if not player.Character then continue end
            local distanceBetweenParts = (player.Character.HumanoidRootPart.Position - self.Instance.PrimaryPart.Position).Magnitude
            self.Instance.PrimaryPart.Color = if distanceBetweenParts < ObserverConfig.Range then Color3.fromRGB(0, 255, 0) else Color3.fromRGB(255, 0, 0)
        end
    end)

	return self
end

function Observer:Destroy()
    self._heartbeatConnection:Disconnect()
end

return Observer