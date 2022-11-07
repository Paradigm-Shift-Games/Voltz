local Bore = {}
Bore.__index = Bore

function Bore.new(instance)
	local self = setmetatable({}, Bore)
	self.Instance = instance
	return self
end

function Bore:Destroy()

end

return Bore