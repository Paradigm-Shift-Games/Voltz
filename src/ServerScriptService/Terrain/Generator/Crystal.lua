local Grid2D = require(script.Parent.Parent.Grid2D)

local Crystal = {}

function Crystal.Generate(crystalConfig, islandGrid)
	local crystalGrid = Grid2D.new()
	local random = Random.new()

	islandGrid:IterateCells(function(position)
		if random:NextNumber() < crystalConfig.CrystalSpawnRate then
			crystalGrid:Set(position.X, position.Y, true)
		end
	end)

	return crystalGrid
end

function Crystal.Build(terrainGrid, crystalGrid)
	crystalGrid:IterateCells(function(position)
		terrainGrid:Set(position.X, 1, position.Y, "Resource Crystal")
	end)
end

return Crystal