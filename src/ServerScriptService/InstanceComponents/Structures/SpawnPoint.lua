local SpawnPoint = {}
SpawnPoint.__index = SpawnPoint

function SpawnPoint.new(instance)
	local self = setmetatable({}, SpawnPoint)
	self.Instance = instance
	return self
end

function SpawnPoint:Destroy()

end

return SpawnPoint