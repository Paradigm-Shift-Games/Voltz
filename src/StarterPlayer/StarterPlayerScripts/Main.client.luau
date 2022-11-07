local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
Knit.AddControllers(ReplicatedStorage.Client.Controllers)

Knit.Start()