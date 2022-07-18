local Valve = {}
Valve.__index = Valve

function Valve.new(instance)
   local self = setmetatable({}, Valve)
   self.Instance = instance
   return self
end

function Valve:Destroy()

end

return Valve