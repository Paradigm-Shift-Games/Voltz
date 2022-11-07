local UpgradeStation = {}
UpgradeStation.__index = UpgradeStation

function UpgradeStation.new(instance)
	local self = setmetatable({}, UpgradeStation)
	self.Instance = instance
	return self
end

function UpgradeStation:Destroy()

end

return UpgradeStation