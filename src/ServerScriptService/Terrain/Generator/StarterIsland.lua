local Grid2D = require(script.Parent.Parent.Grid2D)
local Grid3D = require(script.Parent.Parent.Grid3D)

local StarterIsland = {}

function StarterIsland.Generate(islandConfig, islandGrid)
	return Grid2D.new() -- a grid of starter island positions -> true
end

function StarterIsland.Build(starterIslandConfig, starterIslandGrid)
	-- create the starter islands. They're just circles of 'Surface Fill' around each starter island point
	-- Create **EACH** starter island in a new grid. return an **ARRAY** of starter island grids.
	-- This is neccesary because scripting the starter islands is something that actively has to be done, they need to spawn
	-- players and well-pumps, and lumping them in with the other grid will make this **very** difficult.



	-- return an array of starter island 3D grids
end

return StarterIsland