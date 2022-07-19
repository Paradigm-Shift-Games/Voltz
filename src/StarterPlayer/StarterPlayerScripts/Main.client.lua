local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Common.Loader)

-- Load Game
Loader.GenBinders(ReplicatedStorage.Client.InstanceComponents.Tools)
Loader.GenBinders(ReplicatedStorage.Client.InstanceComponents.Structures)