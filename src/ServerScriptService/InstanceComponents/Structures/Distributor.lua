local Distributor = {}
Distributor.__index = Distributor

function Distributor.new(instance)
   local self = setmetatable({}, Distributor)
   self.Instance = instance
   return self
end

function Distributor:Destroy()

end

return Distributor