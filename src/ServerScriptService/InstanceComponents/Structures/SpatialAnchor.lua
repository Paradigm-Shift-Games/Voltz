local SpatialAnchor = {}
SpatialAnchor.__index = SpatialAnchor

function SpatialAnchor.new(instance)
	local self = setmetatable({}, SpatialAnchor)
	self.Instance = instance
	return self
end

function SpatialAnchor:Destroy()

end

return SpatialAnchor