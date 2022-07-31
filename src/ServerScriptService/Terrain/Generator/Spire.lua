local Grid2D = require(script.Parent.Parent.Grid2D)
local Noise2D = require(script.Parent.Parent.Noise2D)

local Spire = {}

function Spire.Generate(spireConfig, islandGrid)
	local spireGrid = Grid2D.new()

	local cityNoise = Noise2D.new()
	local buildingNoise = Noise2D.new()
	local alleyNoise = Noise2D.new()
	local heightNoise = Noise2D.new()

	islandGrid:IterateCells(function(position)
		local isCity = cityNoise:EdgeRange(position.X, position.Y, spireConfig.Cities.Scale, spireConfig.Cities.Weight)
		local isBuilding = buildingNoise:EdgeRange(position.X, position.Y, spireConfig.Buildings.Scale, spireConfig.Buildings.Weight)
		local isAlley = alleyNoise:EdgeRange(position.X, position.Y, spireConfig.Alleys.Scale, spireConfig.Alleys.Weight)

		if isCity and isBuilding and not isAlley then
			local height = math.floor(heightNoise:UnitNoise(position.X, position.Y, spireConfig.Height.Scale) * spireConfig.Height.Magnitude)
	
			if height > 0 then
				spireGrid:Set(position.X, position.Y, height)
			end
		end
	end)

	return spireGrid
end

function Spire.Build(terrainGrid, spireGrid)
	spireGrid:IterateCells(function(position, height)
		for y = 0, height do
			if y == height then
				terrainGrid:Set(position.X, y, position.Y, "Spire Top")
			else
				terrainGrid:Set(position.X, y, position.Y, "Spire Fill")
			end
		end
	end)
end

return Spire