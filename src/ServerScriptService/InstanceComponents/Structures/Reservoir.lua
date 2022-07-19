local Reservoir = {}
Reservoir.__index = Reservoir

function Reservoir.new(instance)
   local self = setmetatable({}, Reservoir)
   self.Instance = instance
   return self
end

function Reservoir:Destroy()

end

return Reservoir