local Arsenal = {}
Arsenal.__index = Arsenal

function Arsenal.new(instance)
   local self = setmetatable({}, Arsenal)
   self.Instance = instance
   return self
end

function Arsenal:Destroy()

end

return Arsenal