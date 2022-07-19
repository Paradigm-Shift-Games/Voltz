local LaserDrill = {}
LaserDrill.__index = LaserDrill

function LaserDrill.new(instance)
   local self = setmetatable({}, LaserDrill)
   self.Instance = instance
   return self
end

function LaserDrill:Destroy()

end

return LaserDrill