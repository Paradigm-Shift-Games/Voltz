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
	for position, _ in pairs(starterIslandGrid) do
		for x = -islandConfig.StarterIslandSize, islandConfig.StarterIslandSize do
			for z = -islandConfig.StarterIslandSize, islandConfig.StarterIslandSize do

				if math.sqrt(x^2 + z^2) > islandConfig.StarterIslandSize then
					continue
				end

				terrainGrid:Set(position.X + x, 0, position.Z + z, "Surface Fill")
			end
		end

		terrainGrid:Set(position.X, 1, position.Z, "TeamStartPosition")
	end
end

return StarterIsland