local ShieldGenerator = {}
ShieldGenerator.__index = ShieldGenerator

function ShieldGenerator.new(instance)
	local self = setmetatable({}, ShieldGenerator)
	self.Instance = instance
	return self
end

function ShieldGenerator:Destroy()

end

return ShieldGenerator