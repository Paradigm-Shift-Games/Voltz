local LargeTank = {}
LargeTank.__index = LargeTank

function LargeTank.new(instance)
	local self = setmetatable({}, LargeTank)
	self.Instance = instance
	return self
end

function LargeTank:Destroy()

end

return LargeTank