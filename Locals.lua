local getLocals = "getLocals" -- fix bug

function Locals.getLocals(this)
    return this
end
function Locals.local(this, name)
    return this[name]
end
function Locals.set(this, name, value)
    this[name] = value
    return value, name
end
function Locals.new()
    return setmetatable({
        getLocals = Locals[getLocals];
        ["local"] = Locals["local"],
        __index = getLocals
    }, Locals)
end

local locals = Locals.new()
locals.loclas = Locals
return locals