local Gauge = {}
Gauge.__index = Gauge

function Gauge.new(instance)
	local self = setmetatable({}, Gauge)
	self.Instance = instance
	return self
end

function Gauge:Destroy()

end

return Gauge