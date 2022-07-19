local ArcTurret = {}
ArcTurret.__index = ArcTurret

function ArcTurret.new(instance)
   local self = setmetatable({}, ArcTurret)
   self.Instance = instance
   return self
end

function ArcTurret:Destroy()

end

return ArcTurret