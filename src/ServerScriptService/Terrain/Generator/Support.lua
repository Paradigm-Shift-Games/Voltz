local Support = {}

function Support._getMinDistance(supportGrid, canadatePosition)
	local minDistance = math.huge

	for position, _ in pairs(supportGrid) do
		minDistance = math.min(minDistance, (canadatePosition - position).Magnitude)
	end

	return minDistance
end

function Support.Generate(supportConfig, islandGrid, starterIslandGrid)
	local supportGrid = {}

	for position, _ in pairs(islandGrid) do
		if Support._getMinDistance(supportGrid, position) > supportConfig.SupportSpacing then
			supportGrid[position] = true
		end
	end

	for position, _ in pairs(starterIslandGrid) do
		supportGrid[position] = true
	end

	return supportGrid
end

function Support.Build(terrainGrid, supportConfig, supportGrid)
	for position, _ in pairs(supportGrid) do
		for y = -supportConfig.SupportHeight, 0 do
			if y == 0 then
				terrainGrid:Set(position.X, y, position.Z, "Support WellTop")
			else
				terrainGrid:Set(position.X, y, position.Z, "Support Well")
			end
		end
	end

	-- generate each support.

	-- 1/2 of supports are round, the other half are not.
	-- 1/2 of supports are 1x1s, the other half, 3x3s.

	-- Ensure your generation code supports a boolean for 'round', and a integer for radius.

	-- Whether a column is a 'pump', 'ladder', or 'fill' is simply some random function.
	-- I haven't decided what it is, so just use something for now.

	-- Pumps are 'Support Well', except on top, where they are 'Support WellTop'
	-- Ladders are 'Support Ladder'
	-- Fill is 'Support Fill'

	--[[
		1x1, round:
			[ ][ ][ ]
			[ ][*][ ]
			[ ][ ][ ]
	]]

	--[[
		1x1, square:
			[ ][ ][ ]
			[ ][*][ ]
			[ ][ ][ ]
	]]

	--[[
		3x3, square:
			[*][*][*]
			[*][*][*]
			[*][*][*]
	]]

	--[[
		3x3, round:
			[ ][*][ ]
			[*][*][*]
			[ ][*][ ]
	]]

	-- make all modifications to the terrainGrid reference that is passed in.
end

return Support