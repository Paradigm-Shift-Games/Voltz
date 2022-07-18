local Wall = {}
Wall.__index = Wall

function Wall.new(instance)
   local self = setmetatable({}, Wall)
   self.Instance = instance
   return self
end

function Wall:Destroy()

end

return Wall