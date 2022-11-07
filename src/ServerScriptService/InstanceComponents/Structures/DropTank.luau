local DropTank = {}
DropTank.__index = DropTank

function DropTank.new(instance)
	local self = setmetatable({}, DropTank)
	self.Instance = instance
	return self
end

function DropTank:Destroy()

end

return DropTank