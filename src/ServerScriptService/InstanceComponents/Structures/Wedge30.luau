local Wedge30 = {}
Wedge30.__index = Wedge30

function Wedge30.new(instance)
	local self = setmetatable({}, Wedge30)
	self.Instance = instance
	return self
end

function Wedge30:Destroy()

end

return Wedge30