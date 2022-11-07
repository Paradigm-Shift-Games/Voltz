local Transciever = {}
Transciever.__index = Transciever

function Transciever.new(instance)
	local self = setmetatable({}, Transciever)
	self.Instance = instance
	return self
end

function Transciever:Destroy()

end

return Transciever