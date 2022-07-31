local Portafab = {}
Portafab.__index = Portafab

function Portafab.new(instance)
	local self = setmetatable({}, Portafab)
	self.Instance = instance
	return self
end

function Portafab:Destroy()

end

return Portafab