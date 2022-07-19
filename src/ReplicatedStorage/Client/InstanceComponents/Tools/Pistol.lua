local Pistol = {}
Pistol.__index = Pistol

function Pistol.new(instance)
   local self = setmetatable({}, Pistol)
   self.Instance = instance
   return self
end

function Pistol:Destroy()

end

return Pistol