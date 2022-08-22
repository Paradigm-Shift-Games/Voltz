local Crystal = {}

function Crystal.Generate(crystalConfig, islandGrid)
	local crystalGrid = {}
	local random = Random.new()

	for position, _ in islandGrid do
		if random:NextNumber() < crystalConfig.CrystalSpawnRate then
			crystalGrid[Vector3.new(position.X, 0, position.Z)] = true
		end
	end

	return crystalGrid
end

function Crystal.Build(terrainGrid, crystalGrid)
	for position, _ in crystalGrid do
		terrainGrid[position + Vector3.new(0, 1, 0)] = "Resource Crystal"
	end
end

return Crystal