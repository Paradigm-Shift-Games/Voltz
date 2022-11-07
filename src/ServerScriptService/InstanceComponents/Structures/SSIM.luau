local SSIM = {}
SSIM.__index = SSIM

function SSIM.new(instance)
	local self = setmetatable({}, SSIM)
	self.Instance = instance
	return self
end

function SSIM:Destroy()

end

return SSIM