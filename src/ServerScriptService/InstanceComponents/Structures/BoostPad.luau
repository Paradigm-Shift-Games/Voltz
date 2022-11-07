local BoostPad = {}
BoostPad.__index = BoostPad

function BoostPad.new(instance)
	local self = setmetatable({}, BoostPad)
	self.Instance = instance
	return self
end

function BoostPad:Destroy()

end

return BoostPad