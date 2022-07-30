local RocketLauncher = {}
RocketLauncher.__index = RocketLauncher

function RocketLauncher.new(instance)
	local self = setmetatable({}, RocketLauncher)
	self.Instance = instance
	return self
end

function RocketLauncher:Destroy()

end

return RocketLauncher