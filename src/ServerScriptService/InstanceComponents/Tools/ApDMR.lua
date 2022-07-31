local ApDMR = {}
ApDMR.__index = ApDMR

function ApDMR.new(instance)
	local self = setmetatable({}, ApDMR)
	self.Instance = instance
	return self
end

function ApDMR:Destroy()

end

return ApDMR