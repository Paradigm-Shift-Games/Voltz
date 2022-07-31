local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Terrain = require(ServerScriptService.Terrain)

local TerrainGeneratorService = Knit.CreateService {
    Name = "TerrainGeneratorService";
    Client = {};
}

function TerrainGeneratorService:Generate(terrainConfig)
    self._terrainConfig = terrainConfig
    Terrain.Generate(terrainConfig)
end

function TerrainGeneratorService:KnitInit()

end

function TerrainGeneratorService:KnitStart()
    local terrainConfig = require(ReplicatedStorage.Common.Config.Terrain)
    self:Generate(terrainConfig)
end

return TerrainGeneratorService