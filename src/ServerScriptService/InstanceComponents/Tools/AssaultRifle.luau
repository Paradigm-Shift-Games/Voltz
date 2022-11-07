local AssaultRifle = {}
AssaultRifle.__index = AssaultRifle

function AssaultRifle.new(instance)
	local self = setmetatable({}, AssaultRifle)
	self.Instance = instance
	return self
end

function AssaultRifle:Destroy()

end

return AssaultRifle