local GrenadeLauncher = {}
GrenadeLauncher.__index = GrenadeLauncher

function GrenadeLauncher.new(instance)
   local self = setmetatable({}, GrenadeLauncher)
   self.Instance = instance
   return self
end

function GrenadeLauncher:Destroy()

end

return GrenadeLauncher