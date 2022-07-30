local Grid2D = require(script.Parent.Parent.Grid2D)

local Crystal = {}

function Crystal.Generate(crystalConfig, islandGrid)
	return Grid2D.new() -- a grid of crystal positions -> true - do not store the false case, to save memory
	-- this is a very simple random, but it's great for the purposes of being able to extend crystal behaviour later (perhaps to use noise?)
end

function Crystal.Build(terrtainGrid, crystalGrid)
	-- create the crystals in the grid. This is trivial.
	
end

return Crystal