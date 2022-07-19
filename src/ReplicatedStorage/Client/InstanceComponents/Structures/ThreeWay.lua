local ThreeWay = {}
ThreeWay.__index = ThreeWay

function ThreeWay.new(instance)
   local self = setmetatable({}, ThreeWay)
   self.Instance = instance
   return self
end

function ThreeWay:Destroy()

end

return ThreeWay