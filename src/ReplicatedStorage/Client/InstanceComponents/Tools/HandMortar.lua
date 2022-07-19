local HandMortar = {}
HandMortar.__index = HandMortar

function HandMortar.new(instance)
   local self = setmetatable({}, HandMortar)
   self.Instance = instance
   return self
end

function HandMortar:Destroy()

end

return HandMortar