local Noise2D = require(script.Parent.Parent.Noise2D)

local Spire = {}

function Spire.Generate(spireConfig, islandGrid)
	local spireGrid = {}

	local cityNoise = Noise2D.new()
	local buildingNoise = Noise2D.new()
	local alleyNoise = Noise2D.new()
	local heightNoise = Noise2D.new()

	for position, _ in pairs(islandGrid) do
		local isCity = cityNoise:EdgeRange(position.X, position.Z, spireConfig.Cities.Scale, spireConfig.Cities.Weight)
		local isBuilding = buildingNoise:EdgeRange(position.X, position.Z, spireConfig.Buildings.Scale, spireConfig.Buildings.Weight)
		local isAlley = alleyNoise:EdgeRange(position.X, position.Z, spireConfig.Alleys.Scale, spireConfig.Alleys.Weight)

		if isCity and isBuilding and not isAlley then
			local height = math.floor(heightNoise:UnitNoise(position.X, position.Z, spireConfig.Height.Scale) * spireConfig.Height.Magnitude)

			if height > 0 then
				spireGrid[Vector3.new(position.X, 0, position.Z)] = height
			end
		end
	end

	return spireGrid
end

function Spire.Build(terrainGrid, spireGrid)
	for position, height in pairs(spireGrid) do
		for y = 0, height do
			if y == height then
				terrainGrid[position + Vector3.new(0, y, 0)] = "Spire Top"
			else
				terrainGrid[position + Vector3.new(0, y, 0)] = "Spire Fill"
			end
		end
	end
end

return Spire