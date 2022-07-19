local Scanner = {}
Scanner.__index = Scanner

function Scanner.new(instance)
   local self = setmetatable({}, Scanner)
   self.Instance = instance
   return self
end

function Scanner:Destroy()

end

return Scanner