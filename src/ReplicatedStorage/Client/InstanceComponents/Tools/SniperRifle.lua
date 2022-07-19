local SniperRifle = {}
SniperRifle.__index = SniperRifle

function SniperRifle.new(instance)
   local self = setmetatable({}, SniperRifle)
   self.Instance = instance
   return self
end

function SniperRifle:Destroy()

end

return SniperRifle