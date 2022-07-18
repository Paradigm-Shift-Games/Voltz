local Submersible = {}
Submersible.__index = Submersible

function Submersible.new(instance)
   local self = setmetatable({}, Submersible)
   self.Instance = instance
   return self
end

function Submersible:Destroy()

end

return Submersible