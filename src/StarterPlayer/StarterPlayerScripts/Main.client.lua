local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BinderRegistry = require(ReplicatedStorage.Client.BinderRegistry)

for _, componentModule in ipairs(ReplicatedStorage.Client.InstanceComponents.Structures:GetChildren()) do
    BinderRegistry:Add(componentModule.Name, require(componentModule))
end

for _, componentModule in ipairs(ReplicatedStorage.Client.InstanceComponents.Tools:GetChildren()) do
    BinderRegistry:Add(componentModule.Name, require(componentModule))
end

for _, componentModule in ipairs(ReplicatedStorage.Client.InstanceComponents.Misc:GetChildren()) do
    BinderRegistry:Add(componentModule.Name, require(componentModule))
end

BinderRegistry:Start()