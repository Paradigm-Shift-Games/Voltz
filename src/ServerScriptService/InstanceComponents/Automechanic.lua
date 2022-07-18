local Automechanic = {}
Automechanic.__index = Automechanic

function Automechanic.new(instance)
   local self = setmetatable({}, Automechanic)
   self.Instance = instance
   return self
end

function Automechanic:Destroy()

end

return Automechanic