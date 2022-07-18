local HollowBlock = {}
HollowBlock.__index = HollowBlock

function HollowBlock.new(instance)
   local self = setmetatable({}, HollowBlock)
   self.Instance = instance
   return self
end

function HollowBlock:Destroy()

end

return HollowBlock