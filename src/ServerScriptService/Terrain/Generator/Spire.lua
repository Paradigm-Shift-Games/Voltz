local Grid2D = require(script.Parent.Parent.Grid2D)

local Spire = {}

function Spire.Generate(spireConfig, islandGrid)
	return Grid2D.new() -- a grid of spire positions -> height, do not allocate to the grid in the height = 0 case, to save memory
end

function Spire.Build(terrainGrid, spireGrid)
	-- Generate the spires using the height in spireGrid
	
	-- make all modifications to the terrainGrid reference that is passed in.
end

return Spire