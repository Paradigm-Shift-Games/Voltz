local MediumTank = {}
MediumTank.__index = MediumTank

function MediumTank.new(instance)
   local self = setmetatable({}, MediumTank)
   self.Instance = instance
   return self
end

function MediumTank:Destroy()

end

return MediumTank