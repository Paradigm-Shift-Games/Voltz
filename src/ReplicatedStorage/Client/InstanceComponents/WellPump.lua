local WellPump = {}
WellPump.__index = WellPump

function WellPump.new(instance)
   local self = setmetatable({}, WellPump)
   self.Instance = instance
   return self
end

function WellPump:Destroy()

end

return WellPump