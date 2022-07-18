local Fabricator = {}
Fabricator.__index = Fabricator

function Fabricator.new(instance)
   local self = setmetatable({}, Fabricator)
   self.Instance = instance
   return self
end

function Fabricator:Destroy()

end

return Fabricator