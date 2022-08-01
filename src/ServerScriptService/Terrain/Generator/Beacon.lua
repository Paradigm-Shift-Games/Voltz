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
	local beaconAngle = 0

	for y = 0, beaconCount do
		local angleCos = math.cos(math.rad(beaconAngle))
		local angleSin = math.sin(math.rad(beaconAngle))
		beaconGrid:Set(math.round(angleCos * beaconConfig.Offset), math.round(angleSin * beaconConfig.Offset), true)

		beaconAngle = beaconAngleDifference * y
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