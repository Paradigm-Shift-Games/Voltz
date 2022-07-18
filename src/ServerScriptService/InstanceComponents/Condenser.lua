local Condenser = {}
Condenser.__index = Condenser

function Condenser.new(instance)
   local self = setmetatable({}, Condenser)
   self.Instance = instance
   return self
end

function Condenser:Destroy()

end

return Condenser