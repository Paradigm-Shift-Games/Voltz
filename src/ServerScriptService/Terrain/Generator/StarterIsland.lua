local Grid2D = require(script.Parent.Parent.Grid2D)
local Grid3D = require(script.Parent.Parent.Grid3D)

local StarterIsland = {}

function StarterIsland.Generate(islandConfig)
	local starterIslandGrid = Grid2D.new()

	local islandAngleDifference = 360 / islandConfig.StarterIslandAmount

	local offset = islandConfig.MainlandSize + islandConfig.StarterIslandOffset

	for i = 1, islandConfig.StarterIslandAmount do
		local x = math.cos(math.rad(islandAngleDifference * i))
		local y = math.sin(math.rad(islandAngleDifference * i))
		starterIslandGrid:Set(math.round(x * offset), math.round(y * offset), true)
	end

	return starterIslandGrid
end

function StarterIsland.Build(terrainGrid, islandConfig, starterIslandGrid)
	starterIslandGrid:IterateCells(function(position)
		for x = -islandConfig.StarterIslandSize, islandConfig.StarterIslandSize do
			for z = -islandConfig.StarterIslandSize, islandConfig.StarterIslandSize do

				if math.sqrt(x^2 + z^2) > islandConfig.StarterIslandSize then
					continue
				end

				terrainGrid:Set(position.X + x, 0, position.Y + z, "Surface Fill")
			end
		end

		terrainGrid:Set(position.X, 1, position.Y, "TeamStartPosition")
	end)
end

return StarterIsland