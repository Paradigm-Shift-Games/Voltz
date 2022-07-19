local Shotgun = {}
Shotgun.__index = Shotgun

function Shotgun.new(instance)
   local self = setmetatable({}, Shotgun)
   self.Instance = instance
   return self
end

function Shotgun:Destroy()

end

return Shotgun