local FourWay = {}
FourWay.__index = FourWay

function FourWay.new(instance)
	local self = setmetatable({}, FourWay)
	self.Instance = instance
	return self
end

function FourWay:Destroy()

end

return FourWay