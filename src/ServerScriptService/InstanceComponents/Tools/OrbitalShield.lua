local OrbitalShield = {}
OrbitalShield.__index = OrbitalShield

function OrbitalShield.new(instance)
   local self = setmetatable({}, OrbitalShield)
   self.Instance = instance
   return self
end

function OrbitalShield:Destroy()

end

return OrbitalShield