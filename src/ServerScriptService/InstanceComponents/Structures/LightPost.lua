local LightPost = {}
LightPost.__index = LightPost

function LightPost.new(instance)
   local self = setmetatable({}, LightPost)
   self.Instance = instance
   return self
end

function LightPost:Destroy()

end

return LightPost