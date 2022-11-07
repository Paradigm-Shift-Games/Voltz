local SMG = {}
SMG.__index = SMG

function SMG.new(instance)
	local self = setmetatable({}, SMG)
	self.Instance = instance
	return self
end

function SMG:Destroy()

end

return SMG