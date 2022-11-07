local Ladder = {}
Ladder.__index = Ladder

function Ladder.new(instance)
	local self = setmetatable({}, Ladder)
	self.Instance = instance
	return self
end

function Ladder:Destroy()

end

return Ladder