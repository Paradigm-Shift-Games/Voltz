local Keep = {}
Keep.__index = Keep

function Keep.new(instance)
   local self = setmetatable({}, Keep)
   self.Instance = instance
   return self
end

function Keep:Destroy()

end

return Keep