local CruiseMissle = {}
CruiseMissle.__index = CruiseMissle

function CruiseMissle.new(instance)
   local self = setmetatable({}, CruiseMissle)
   self.Instance = instance
   return self
end

function CruiseMissle:Destroy()

end

return CruiseMissle