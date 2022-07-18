local Block = {}
Block.__index = Block

function Block.new(instance)
   local self = setmetatable({}, Block)
   self.Instance = instance
   return self
end

function Block:Destroy()

end

return Block