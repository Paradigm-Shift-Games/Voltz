local SlabBlock = {}
SlabBlock.__index = SlabBlock

function SlabBlock.new(instance)
   local self = setmetatable({}, SlabBlock)
   self.Instance = instance
   return self
end

function SlabBlock:Destroy()

end

return SlabBlock