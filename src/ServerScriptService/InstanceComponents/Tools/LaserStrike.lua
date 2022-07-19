local LaserStrike = {}
LaserStrike.__index = LaserStrike

function LaserStrike.new(instance)
   local self = setmetatable({}, LaserStrike)
   self.Instance = instance
   return self
end

function LaserStrike:Destroy()

end

return LaserStrike