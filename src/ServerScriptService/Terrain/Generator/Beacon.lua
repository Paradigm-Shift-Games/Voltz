local Beacon = {}

function Beacon.Generate(beaconConfig)
	local beaconGrid = {}

	if beaconConfig.BeaconCount == 0 then
		return beaconGrid
	end

	local beaconCount = beaconConfig.BeaconCount - 1

	beaconGrid[Vector3.new(0, 0, 0)] = true
	local beaconAngleDifference = 360 / beaconCount

	for i = 1, beaconCount do
		local x = math.cos(math.rad(beaconAngleDifference * i))
		local y = math.sin(math.rad(beaconAngleDifference * i))
		beaconGrid[Vector3.new(math.round(x * beaconConfig.Offset), 0, math.round(y * beaconConfig.Offset))] = true
	end

	return beaconGrid
end


function Beacon.Build(terrainGrid, supportConfig, beaconGrid)
	for position, _ in pairs(beaconGrid) do
		for y = -supportConfig.SupportHeight, 0 do
			if y == 0 then
				terrainGrid[position + Vector3.new(0, y, 0)] = "Support Beacon"
			else
				terrainGrid[position + Vector3.new(0, y, 0)] = "Surface Fill"
			end
		end
	end
end

return Beacon