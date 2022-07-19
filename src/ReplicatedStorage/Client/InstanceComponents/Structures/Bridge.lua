local Bridge = {}
Bridge.__index = Bridge

function Bridge.new(instance)
   local self = setmetatable({}, Bridge)
   self.Instance = instance
   return self
end

function Bridge:Destroy()

end

return Bridge