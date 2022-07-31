local Grid2D = require(script.Parent.Parent.Grid2D)

local Beacon = {}

function Beacon.Generate(islandConfig, beaconConfig)
	return Grid2D.new() -- a grid of beacon positions -> true
	-- this is some very simple math. simply add a beacon to the center, then the additional beacons are half way out from the island, in a circular pattern.
	-- be sure to not add decimals to the generator - rounding is important
end

function Beacon.Build(terrainGrid, supportConfig, beaconGrid)
	-- actually create the beacons, They're made of 'Support Fill', except for layer 0, which is made of 'Support Beacon'
end

return Beacon