local Gate = {}
Gate.__index = Gate

function Gate.new(instance)
	local self = setmetatable({}, Gate)
	self.Instance = instance
	return self
end

function Gate:Destroy()

end

return Gate