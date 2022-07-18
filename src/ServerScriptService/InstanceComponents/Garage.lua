local Garage = {}
Garage.__index = Garage

function Garage.new(instance)
   local self = setmetatable({}, Garage)
   self.Instance = instance
   return self
end

function Garage:Destroy()

end

return Garage