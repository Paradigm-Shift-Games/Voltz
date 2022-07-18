local DistributorCap = {}
DistributorCap.__index = DistributorCap

function DistributorCap.new(instance)
   local self = setmetatable({}, DistributorCap)
   self.Instance = instance
   return self
end

function DistributorCap:Destroy()

end

return DistributorCap