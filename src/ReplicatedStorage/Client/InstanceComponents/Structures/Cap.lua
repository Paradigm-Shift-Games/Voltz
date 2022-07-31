local Cap = {}
Cap.__index = Cap

function Cap.new(instance)
	local self = setmetatable({}, Cap)
	self.Instance = instance
	return self
end

function Cap:Destroy()

end

return Cap