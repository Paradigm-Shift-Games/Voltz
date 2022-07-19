local Artillery = {}
Artillery.__index = Artillery

function Artillery.new(instance)
   local self = setmetatable({}, Artillery)
   self.Instance = instance
   return self
end

function Artillery:Destroy()

end

return Artillery