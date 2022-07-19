local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Loader = require(ReplicatedStorage.Common.Loader)

-- Load Game
Loader.GenBinders(ServerScriptService.InstanceComponents.Tools)
Loader.GenBinders(ServerScriptService.InstanceComponents.Structures)