local Grid2D = require(script.Parent.Parent.Grid2D)

local Island = {}

function Island.Generate(islandConfig)
	return Grid2D.new() -- a grid of positions where there should be island -> depth
	-- this is where circular math and gap map is handled.
	-- additionally, we're storing depth in this map, so we can generate it later.
end

function Island.Build(terrainGrid, islandConfig)
	-- generate the actual islands. The surface is islands is either 'Surface Fill' or 'Surface Grass', depending on the grass noise layer.
	-- the underground is always 'Surface Fill'
end

return Island