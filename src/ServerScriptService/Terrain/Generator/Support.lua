local Grid2D = require(script.Parent.Parent.Grid2D)

local Support = {}

function Support.Generate(supportConfig, islandGrid, starterIslandGrid)
	return Grid2D.new() -- a grid of support positions -> true
end

function Support.Build(terrainGrid, supportConfig, supportGrid)
	-- generate each support.

	-- 1/2 of supports are round, the other half are not.
	-- 1/2 of supports are 1x1s, the other half, 3x3s.

	-- Ensure your generation code supports a boolean for 'round', and a integer for

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