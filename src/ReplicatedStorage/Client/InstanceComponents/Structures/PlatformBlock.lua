local PlatformBlock = {}
PlatformBlock.__index = PlatformBlock

function PlatformBlock.new(instance)
   local self = setmetatable({}, PlatformBlock)
   self.Instance = instance
   return self
end

function PlatformBlock:Destroy()

end

return PlatformBlock