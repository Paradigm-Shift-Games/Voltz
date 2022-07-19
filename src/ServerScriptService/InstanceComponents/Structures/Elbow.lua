local Elbow = {}
Elbow.__index = Elbow

function Elbow.new(instance)
   local self = setmetatable({}, Elbow)
   self.Instance = instance
   return self
end

function Elbow:Destroy()

end

return Elbow