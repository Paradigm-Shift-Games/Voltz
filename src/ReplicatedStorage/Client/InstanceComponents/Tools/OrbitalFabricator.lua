local OrbitalFabricator = {}
OrbitalFabricator.__index = OrbitalFabricator

function OrbitalFabricator.new(instance)
   local self = setmetatable({}, OrbitalFabricator)
   self.Instance = instance
   return self
end

function OrbitalFabricator:Destroy()

end

return OrbitalFabricator