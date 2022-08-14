local Grid2D = require(script.Parent.Parent.Grid2D)
local Grid3D = require(script.Parent.Parent.Grid3D)

local StarterIsland = {}

function StarterIsland.Generate(islandConfig)
	local islandGrid = Grid2D.new()

	local islandAngleDifference = 360 / islandConfig.StarterIslandAmount

	local offset = islandConfig.MainlandSize + islandConfig.StarterIslandOffset

	for i = 1, islandConfig.StarterIslandAmount do
		local x = math.cos(math.rad(islandAngleDifference * i))
		local y = math.sin(math.rad(islandAngleDifference * i))
		islandGrid:Set(math.round(x * offset), math.round(y * offset), true)
	end

	return islandGrid
end

function StarterIsland.Build(terrainGrid, islandConfig, starterIslandGrid)
	-- create the starter islands. They're just circles of 'Surface Fill' around each starter island point
	-- Create **EACH** starter island in a new grid. return an **ARRAY** of starter island grids.
	-- This is neccesary because scripting the starter islands is something that actively has to be done, they need to spawn
	-- players and well-pumps, and lumping them in with the other grid will make this **very** difficult.

	starterIslandGrid:IterateCells(function(position)
		for x = -islandConfig.StarterIslandSize, islandConfig.StarterIslandSize do
			for z = -islandConfig.StarterIslandSize, islandConfig.StarterIslandSize do

				if math.sqrt(x^2 + z^2) > islandConfig.StarterIslandSize then
					continue
				end

				terrainGrid:Set(position.X + x, 0, position.Y + z, "Surface Fill")
			end
		end
	end)
	-- return an array of starter island 3D grids
end

return StarterIsland