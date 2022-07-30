local SmallTank = {}
SmallTank.__index = SmallTank

function SmallTank.new(instance)
	local self = setmetatable({}, SmallTank)
	self.Instance = instance
	return self
end

function SmallTank:Destroy()

end

return SmallTank