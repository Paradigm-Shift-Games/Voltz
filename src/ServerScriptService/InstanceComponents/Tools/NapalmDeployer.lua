local NapalmDeployer = {}
NapalmDeployer.__index = NapalmDeployer

function NapalmDeployer.new(instance)
   local self = setmetatable({}, NapalmDeployer)
   self.Instance = instance
   return self
end

function NapalmDeployer:Destroy()

end

return NapalmDeployer