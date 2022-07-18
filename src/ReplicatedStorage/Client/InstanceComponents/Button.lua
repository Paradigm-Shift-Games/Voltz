local Button = {}
Button.__index = Button

function Button.new(instance: Instance)
    local self = setmetatable({}, Button)
    self.Instance = instance
    return self
end

function Button:Press()
    self.Instance.Press:FireServer()
end

function Button:Destroy()

end

return Button