local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Binder = require(ReplicatedStorage.Packages.Binder)

local Loader = {}

function Loader.LoadChildren(parent)
    local modules = {}

    for _, child in ipairs(parent:GetChildren()) do
        modules[child.Name] = require(child)
    end

    return modules
end

function Loader.CreateBinders(classes)
    local binders = {}

    for tagName, class in pairs(classes) do
        binders[tagName] = Binder.new(tagName, class)
    end

    return binders
end

function Loader.StartBinders(binders)
    for _, binder in ipairs(binders) do
        binder:Start()
    end
end

function Loader.GenBinders(parent)
    local modules = Loader.LoadChildren(parent)
    local binders = Loader.CreateBinders(modules)
    Loader.StartBinders(binders)
end

return Loader