local Turret = {}
Turret.__index = Turret

function Turret.new(instance)
	local self = setmetatable({}, Turret)
	self.Instance = instance
	return self
end

function Turret:Destroy()

end

return Turret