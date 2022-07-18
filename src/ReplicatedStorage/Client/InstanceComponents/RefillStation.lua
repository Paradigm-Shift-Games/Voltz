local RefillStation = {}
RefillStation.__index = RefillStation

function RefillStation.new(instance)
   local self = setmetatable({}, RefillStation)
   self.Instance = instance
   return self
end

function RefillStation:Destroy()

end

return RefillStation