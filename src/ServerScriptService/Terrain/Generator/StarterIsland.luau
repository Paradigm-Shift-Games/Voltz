local StarterIsland = {}

function StarterIsland.Generate(islandConfig)
	local starterIslandGrid = {}

	local islandAngleDifference = 360 / islandConfig.StarterIslandAmount
	local offset = islandConfig.MainlandSize + islandConfig.StarterIslandOffset

	for i = 1, islandConfig.StarterIslandAmount do
		local x = math.cos(math.rad(islandAngleDifference * i))
		local z = math.sin(math.rad(islandAngleDifference * i))
		starterIslandGrid[Vector3.new(math.round(x * offset), 0, math.round(z * offset))] = true
	end

	return starterIslandGrid
end

function StarterIsland.Build(terrainGrid, islandConfig, starterIslandGrid)
	for position, _ in starterIslandGrid do
		for x = -islandConfig.StarterIslandSize, islandConfig.StarterIslandSize do
			for z = -islandConfig.StarterIslandSize, islandConfig.StarterIslandSize do
				if math.sqrt(x^2 + z^2) > islandConfig.StarterIslandSize then
					continue
				end

				terrainGrid[position + Vector3.new(x, 0, z)] = "Surface Fill"
			end
		end

		terrainGrid[position + Vector3.new(0, 1, 0)] = "TeamStartPosition"
	end
end

return StarterIsland