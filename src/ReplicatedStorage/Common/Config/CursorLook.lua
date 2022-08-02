local CursorLookConfig = {
	-- Speed for rotating the character itself
	LookAngularSpeed = math.rad(600);

	-- Speed & bounds for rotating the root
	RootAngularSpeed = Vector3.new(180, 0) * math.rad(1);
	RootUpperBounds = Vector3.new(20, 30, 0) * math.rad(1);
	RootLowerBounds = Vector3.new(-55, -30, 0) * math.rad(1);

	-- Speed & bounds for rotating the waist
	WaistAngularSpeed = Vector3.new(200, 360) * math.rad(1);
	WaistUpperBounds = Vector3.new(30, 35, 0) * math.rad(1);
	WaistLowerBounds = Vector3.new(-55, -35, 0) * math.rad(1);

	-- Speed & bounds for rotating the neck
	NeckAngularSpeed = Vector3.new(300, 560) * math.rad(1);
	NeckUpperBounds = Vector3.new(25, 45, 0) * math.rad(1);
	NeckLowerBounds = Vector3.new(-35, -45, 0) * math.rad(1);
}

return CursorLookConfig