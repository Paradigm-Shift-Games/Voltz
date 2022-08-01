local Grid2D = require(script.Parent.Parent.Grid2D)

local Beacon = {}

function Beacon.Generate(beaconConfig)
	local beaconGrid = Grid2D.new()

	if beaconConfig.BeaconCount == 0 then
		return beaconGrid
	end

	local beaconCount = beaconConfig.BeaconCount - 1

	beaconGrid:Set(0, 0, true)
	local beaconAngleDifference = 360 / beaconCount

	for i = 1, beaconCount do
		local X = math.cos(math.rad(beaconAngleDifference * i))
		local Y = math.sin(math.rad(beaconAngleDifference * i))
		beaconGrid:Set(math.round(X * beaconConfig.Offset), math.round(Y * beaconConfig.Offset), true)
	end

	return beaconGrid
end


function Beacon.Build(terrainGrid, supportConfig, beaconGrid)
	beaconGrid:IterateCells(function(position)
		for y = -supportConfig.SupportHeight, 0 do
			if y == 0 then
				terrainGrid:Set(position.X, y, position.Y, "Support Beacon")
			else
				terrainGrid:Set(position.X, y, position.Y, "Surface Fill")
			end
		end
	end)
end

return Beacon