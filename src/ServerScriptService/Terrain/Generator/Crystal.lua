local Grid2D = require(script.Parent.Parent.Grid2D)

local Crystal = {}

function Crystal.Generate(crystalConfig, islandGrid)
	local crystalGrid = Grid2D.new()

	islandGrid:IterateCells(function(position)
		if math.random() < crystalConfig.CrystalSpawnRate then
			crystalGrid:Set(position.X, position.Y, true)
		end
	end)

	return crystalGrid
end

function Crystal.Build(terrtainGrid, crystalGrid)
	crystalGrid:IterateCells(function(position)
		terrtainGrid:Set(position.X, 1, position.Y, "Resource Crystal")
	end)
end

return Crystal