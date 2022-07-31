-- Classes
local Grid3D = require(script.Parent.Grid3D)

-- Generators
local IslandGenerator = require(script.Island)
local SpireGenerator = require(script.Spire)
local CrystalGenerator = require(script.Crystal)
local BeaconGenerator = require(script.Beacon)
local SupportGenerator = require(script.Support)
local StarterIslandGenerator = require(script.StarterIsland)

local Generator = {}

function Generator.Generate(terrainConfig)
	-- Config
	local islandConfig = terrainConfig.Island
	local crystalConfig = terrainConfig.Crystal
	local beaconConfig = terrainConfig.Beacon
	local supportConfig = terrainConfig.Support
	local spireConfig = terrainConfig.Spire

	-- Generate Grids
	local islandGrid = IslandGenerator.Generate(islandConfig)
	local starterIslandGrid = IslandGenerator.Generate(islandConfig)
	local supportGrid = SupportGenerator.Generate(supportConfig, islandGrid, starterIslandGrid)
	local beaconGrid = BeaconGenerator.Generate(islandConfig, beaconConfig)
	local spireGrid = SpireGenerator.Generate(spireConfig, islandGrid)
	local crystalGrid = CrystalGenerator.Generate(crystalConfig, islandGrid)

	-- Create 3D Grid
	local terrainGrid = Grid3D.new()

	-- Build Islands
	IslandGenerator.Build(terrainGrid, islandConfig, islandGrid)
	CrystalGenerator.Build(terrainGrid, crystalGrid)
	SpireGenerator.Build(terrainGrid, spireGrid)

	-- Build Supports
	SupportGenerator.Build(terrainGrid, supportConfig, supportGrid)
	BeaconGenerator.Build(terrainGrid, supportConfig, beaconGrid)

	-- Build Starter Islands
	local starterIslandGrids = StarterIslandGenerator.Build()

    -- Pack Result
    local resultGrids = {
        Terrain = terrainGrid;
        StarterIslands = starterIslandGrids;
    }

	return resultGrids
end

return Generator