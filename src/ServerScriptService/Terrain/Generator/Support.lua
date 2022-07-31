local Grid2D = require(script.Parent.Parent.Grid2D)

local Support = {}

function Support._getMinDistance(supportGrid, canadatePosition)
	local minDistance = math.huge

	supportGrid:IterateCells(function(position)
		minDistance = math.min(minDistance, (canadatePosition - position).Magnitude)
	end)

	return minDistance
end

function Support.Generate(supportConfig, islandGrid, starterIslandGrid)
	local supportGrid = Grid2D.new()

	islandGrid:IterateCells(function(position)
		if Support._getMinDistance(supportGrid, position) > supportConfig.SupportSpacing then
			supportGrid:Set(position.X, position.Y, true)
		end
	end)

	return supportGrid
end

function Support.Build(terrainGrid, supportConfig, supportGrid)
	supportGrid:IterateCells(function(position)
		for y = -supportConfig.SupportHeight, 0 do
			if y == 0 then
				terrainGrid:Set(position.X, y, position.Y, "Support WellTop")
			else
				terrainGrid:Set(position.X, y, position.Y, "Support Well")
			end
		end
	end)

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