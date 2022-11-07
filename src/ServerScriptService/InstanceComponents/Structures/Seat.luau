local Seat = {}
Seat.__index = Seat

function Seat.new(instance)
	local self = setmetatable({}, Seat)
	self.Instance = instance
	return self
end

function Seat:Destroy()

end

return Seat