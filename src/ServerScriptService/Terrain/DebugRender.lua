local DebugRender = {}

local debugColors = {
	-- Support
	["Support Fill"] = Color3.new(0.164706, 0.168627, 0.254902);
	["Support Well"] = Color3.new(0.309804, 0.145098, 0.00392157);
	["Support WellTop"] = Color3.new(0.478431, 0.286275, 0);
	["Support Beacon"] = Color3.new(1, 0.968627, 0.00392157);

	-- Spire
	["Spire Fill"] = Color3.new(0.247059, 0.219608, 0.027451);
	["Spire Top"] = Color3.new(0.14902, 0.247059, 0.0196078);

	-- Surface
	["Surface Fill"] = Color3.new(0.329412, 0.329412, 0.329412);
	["Surface Grass"] = Color3.new(0.023529, 0.572549, 0.050980);

	-- Resource
	["Resource Crystal"] = Color3.new(0, 1, 0.968627);
}

local function getColor(cellType)
	if debugColors[cellType] then
		return debugColors[cellType]
	else
		warn("Invalid Cell Type: " .. tostring(cellType))
		return Color3.new(1, 0, 1)
	end
end

function DebugRender.DrawGrid(terrainGrid, scale)
	scale = scale or 1

	local folder = Instance.new("Folder")
	folder.Name = "Map"

	terrainGrid:IterateCells(function(position, data)
		local part = Instance.new("Part")

		-- Base properties
		part.Name = data
		part.Anchored = true
		part.Material = Enum.Material.SmoothPlastic

		-- Physical properties
		part.Position = position * scale
		part.Size = Vector3.new(1, 1, 1) * scale
		part.Color = getColor(data)

		part.Parent = folder
	end)

	folder.Parent = workspace
end

return DebugRender