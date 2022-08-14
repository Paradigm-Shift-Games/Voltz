local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Settings = require(ReplicatedStorage.Common.Config.Terrain)
local MinimumRange = Settings.MinimumRange

local Observer = {}
Observer.__index = Observer

function Observer.new(instance)
	local self = setmetatable({}, Observer)
	self.Instance = instance

    print(self.Instance.Name, " created!")

    RunService.Heartbeat:Connect(function()
        for _,v in pairs(Players:GetPlayers()) do
            if not v.Character then return end
            local distanceBetweenParts = (v.Character.HumanoidRootPart.Position - self.Instance.PrimaryPart.Position).Magnitude
            if distanceBetweenParts > MinimumRange then
                self.Instance.PrimaryPart.Color = Color3.fromRGB(0,255,0)
            else
                self.Instance.PrimaryPart.Color = Color3.fromRGB(255,0,0)
            end
        end
    end)

	return self
end

function Observer:Destroy()

    print(self.Instance.Name, " destroyed!")

end

return Observer