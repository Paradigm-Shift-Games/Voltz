local PriorityBeacon = {}
PriorityBeacon.__index = PriorityBeacon

function PriorityBeacon.new(instance)
   local self = setmetatable({}, PriorityBeacon)
   self.Instance = instance
   return self
end

function PriorityBeacon:Destroy()

end

return PriorityBeacon