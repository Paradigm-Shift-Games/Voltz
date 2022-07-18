local Pipe = {}
Pipe.__index = Pipe

function Pipe.new(instance)
   local self = setmetatable({}, Pipe)
   self.Instance = instance
   return self
end

function Pipe:Destroy()

end

return Pipe