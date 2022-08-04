local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.Knit)
Knit.AddServices(ServerScriptService.Services)

Knit.Start()

require(ReplicatedStorage.Common.Util.Zone)