local HighPowerPhotonLancer = {}
HighPowerPhotonLancer.__index = HighPowerPhotonLancer

function HighPowerPhotonLancer.new(instance)
	local self = setmetatable({}, HighPowerPhotonLancer)
	self.Instance = instance
	return self
end

function HighPowerPhotonLancer:Destroy()

end

return HighPowerPhotonLancer