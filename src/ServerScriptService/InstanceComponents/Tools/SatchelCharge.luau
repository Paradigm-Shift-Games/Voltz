local SatchelCharge = {}
SatchelCharge.__index = SatchelCharge

function SatchelCharge.new(instance)
	local self = setmetatable({}, SatchelCharge)
	self.Instance = instance
	return self
end

function SatchelCharge:Destroy()

end

return SatchelCharge