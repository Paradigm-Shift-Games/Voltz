local Wedge45 = {}
Wedge45.__index = Wedge45

function Wedge45.new(instance)
	local self = setmetatable({}, Wedge45)
	self.Instance = instance
	return self
end

function Wedge45:Destroy()

end

return Wedge45