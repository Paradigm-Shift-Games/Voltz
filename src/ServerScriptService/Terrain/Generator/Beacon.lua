local Grid2D = require(script.Parent.Parent.Grid2D)

local Beacon = {}

function Beacon.Generate(beaconConfig)
	local beaconGrid = Grid2D.new()

	beaconGrid:Set(0, 0, true)
	local beaconAngleDifference = 360 / beaconConfig.BeaconCount
	local beaconAngle = 0

	for y = 0, beaconConfig.BeaconCount do
		beaconGrid:Set(math.round(math.cos(math.rad(beaconAngle))* beaconConfig.Offset), math.round(math.sin(math.rad(beaconAngle))* beaconConfig.Offset), true)

		beaconAngle += beaconAngleDifference
	end

	return beaconGrid
end

function Beacon.Build(terrainGrid, supportConfig, beaconGrid)
	beaconGrid:IterateCells(function(position)
		for y = 0, -supportConfig.SupportHeight, -1 do
			if y == 0 then
				terrainGrid:Set(position.X, y, position.Y, "Support Beacon")
			else
				terrainGrid:Set(position.X, y, position.Y, "Surface Fill")
			end
		end
	end)
end

return Beacon