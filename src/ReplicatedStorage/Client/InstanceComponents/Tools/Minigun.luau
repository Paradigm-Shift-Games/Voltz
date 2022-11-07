local Minigun = {}
Minigun.__index = Minigun

function Minigun.new(instance)
	local self = setmetatable({}, Minigun)
	self.Instance = instance
	return self
end

function Minigun:Destroy()

end

return Minigun