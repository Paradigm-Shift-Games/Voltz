local ServerScriptService = game:GetService("ServerScriptService")

local BinderRegistry = require(ServerScriptService.BinderRegistry)

for _, componentModule in ipairs(ServerScriptService.InstanceComponents.Structures:GetChildren()) do
    BinderRegistry:Add(componentModule.Name, require(componentModule))
end

for _, componentModule in ipairs(ServerScriptService.InstanceComponents.Tools:GetChildren()) do
    BinderRegistry:Add(componentModule.Name, require(componentModule))
end

for _, componentModule in ipairs(ServerScriptService.InstanceComponents.Misc:GetChildren()) do
    BinderRegistry:Add(componentModule.Name, require(componentModule))
end

BinderRegistry:Start()