local PointDefense = {}
PointDefense.__index = PointDefense

function PointDefense.new(instance)
	local self = setmetatable({}, PointDefense)
	self.Instance = instance
	return self
end

function PointDefense:Destroy()

end

return PointDefense