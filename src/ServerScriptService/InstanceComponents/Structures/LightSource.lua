local LightSource = {}
LightSource.__index = LightSource

function LightSource.new(instance)
	local self = setmetatable({}, LightSource)
	self.Instance = instance
	return self
end

function LightSource:Destroy()

end

return LightSource