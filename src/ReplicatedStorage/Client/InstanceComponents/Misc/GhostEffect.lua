local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

local GhostEffect = {}
GhostEffect.__index = GhostEffect

local function modifyTransparency(transparency, modifier)
    return transparency + (1 - transparency) * modifier
end

function GhostEffect:_getColor()
    if self._isPlaceable then
        return Color3.new(0, 1, 0)
    else
        return Color3.new(1, 0, 0)
    end
end

function GhostEffect:_getTransparency(part: BasePart)
    if self._isVisible then
        return modifyTransparency(self._partData[part].Transparency, 0.5)
    else
        return 1
    end
end

function GhostEffect:_revert(part: BasePart)
    for property, value in pairs(self._partData[part]) do
        part[property] = value
    end
end

function GhostEffect:_revertAll()
    for part, _ in pairs(self._partData) do
        self:_revert(part)
    end
end

function GhostEffect:_apply(part: BasePart)
    part.CanCollide = false
    part.Color = self:_getColor()
    part.Transparency = self:_getTransparency(part)
end

function GhostEffect:_applyAll()
    for part, _ in pairs(self._partData) do
        self:_apply(part)
    end
end

function GhostEffect:_add(part: BasePart)
    self._partData[part] = {
        Color = part.Color;
        Transparency = part.Transparency;
        CanCollide = part.CanCollide;
    }

    self:_apply(part)
end

function GhostEffect:_setVisible(isVisible: boolean)
    self._isVisible = isVisible
    self:_applyAll()
end

function GhostEffect:_setPlaceable(isPlaceable: boolean)
    self._isPlaceable = isPlaceable
    self:_applyAll()
end

function GhostEffect.new(instance: Instance)
    local self = setmetatable({}, GhostEffect)

    self.Instance = instance
    self._trove = Trove.new()
    self._partData = {}

    self._trove:Connect(self.Instance:GetAttributeChangedSignal("Placeable"), function()
        self:_setPlaceable(self.Instance:GetAttribute("Placeable"))
    end)

    self._trove:Connect(self.Instance:GetAttributeChangedSignal("Visible"), function()
        self:_setVisible(self.Instance:GetAttribute("Visible"))
    end)

    self._trove:Add(function()
        self:_revertAll()
    end)

    self:_setVisible(self.Instance:GetAttribute("Visible"))
    self:_setPlaceable(self.Instance:GetAttribute("Placeable"))

    for _, descendant in ipairs(self.Instance:GetDescendants()) do
        if not descendant:IsA("BasePart") then
            continue
        end

        self:_add(descendant)
    end

    return self
end

function GhostEffect:Destroy()
    self._trove:Clean()
end

return GhostEffect