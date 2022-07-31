local Grid2D = require(script.Parent.Parent.Grid2D)
local Noise2D = require(script.Parent.Parent.Noise2D)

local Island = {}

-- TODO: Gaps
-- TODO: Variable height

function Island.Generate(islandConfig)
	local islandGrid = Grid2D.new()
	local islandNoise = Noise2D.new()
	local depthNoise = Noise2D.new()

	for x = -islandConfig.MainlandSize, islandConfig.MainlandSize do
		for z = -islandConfig.MainlandSize, islandConfig.MainlandSize do
			-- Circle
			if math.sqrt(x^2 + z^2) > islandConfig.MainlandSize then
				continue
			end

			-- Gaps
			if islandNoise:Range(x, z, islandConfig.Gaps.Scale, islandConfig.Gaps.Weight) then
				continue
			end

			-- Depth
			local depth = math.floor(depthNoise:UnitNoise(x, z, islandConfig.Depth.Scale) * islandConfig.Depth.Magnitude)

			-- Grid
			islandGrid:Set(x, z, depth)
		end
	end

	return islandGrid
end

function Island.Build(terrainGrid, islandConfig, islandGrid)
	local grassNoise = Noise2D.new()

	islandGrid:IterateCells(function(position, depth)
		local isGrass = grassNoise:EdgeRange(position.X, position.Y, islandConfig.Grass.Scale, islandConfig.Grass.Weight)

		for y = -depth, 0 do
			if y == 0 and isGrass then
				terrainGrid:Set(position.X, y, position.Y, "Surface Grass")
			else
				terrainGrid:Set(position.X, y, position.Y, "Surface Fill")
			end
		end
		
	end)
end

return Island