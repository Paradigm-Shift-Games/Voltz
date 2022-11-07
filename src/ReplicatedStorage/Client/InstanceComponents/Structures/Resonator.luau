local Resonator = {}
Resonator.__index = Resonator

function Resonator.new(instance)
	local self = setmetatable({}, Resonator)
	self.Instance = instance
	return self
end

function Resonator:Destroy()

end

return Resonator