local AutoFlechette = {}
AutoFlechette.__index = AutoFlechette

function AutoFlechette.new(instance)
   local self = setmetatable({}, AutoFlechette)
   self.Instance = instance
   return self
end

function AutoFlechette:Destroy()

end

return AutoFlechette