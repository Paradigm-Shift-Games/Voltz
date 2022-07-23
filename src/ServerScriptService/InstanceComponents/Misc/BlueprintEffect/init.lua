local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)

local BlueprintEffect = {}
BlueprintEffect.__index = BlueprintEffect

local function modifyTransparency(transparency, modifier)
    return transparency + (1 - transparency) * modifier
end

local function getKeys(map)
    local keys = {}

    for key, _ in pairs(map) do
        table.insert(keys, key)
    end

    return keys
end

local function getDistances(part, parts)
    local distances = {}

    for _, otherPart in ipairs(parts) do
        distances[otherPart] = (part.Position - otherPart.Position).Magnitude
    end

    return distances
end

function BlueprintEffect:_revert(part)
    for property, value in pairs(self._partData[part]) do
        part[property] = value
    end
end

function BlueprintEffect:_revertAll()
    for part, _ in pairs(self._partData) do
        self:_revert(part)
    end
end

function BlueprintEffect:_getColor(unit)
    return Color3.new(0, 0, 0):Lerp(Color3.new(0, 1, 1), unit)
end

function BlueprintEffect:_updatePart(part)
    local fill = self._partFills[part]
    local capacity = self._partCapacities[part]

    part.CanCollide = false
    part.Transparency = modifyTransparency(self._partData[part].Transparency, 0.5)
    part.Color = self:_getColor(fill / capacity)
end

function BlueprintEffect:_getSorted(part)
    if not self._sortedCache[part] then
        local parts = getKeys(self._partData)
        local distances = getDistances(part, parts)

        table.sort(parts, function(a, b)
            return distances[a] < distances[b]
        end)

        self._sortedCache[part] = parts
    end

    return self._sortedCache[part]
end

function BlueprintEffect:_add(part: BasePart)
    self._partData[part] = {
        Color = part.Color;
        Transparency = part.Transparency;
        CanCollide = part.CanCollide;
    }
end

function BlueprintEffect:_addParts()
    for _, descendant in ipairs(self.Instance:GetDescendants()) do
        if not descendant:IsA("BasePart") then
            continue
        end

        self:_add(descendant)
    end
end

function BlueprintEffect:_buildWeights(totalCapacity)
    local partVolumes = {}

    for part, _ in pairs(self._partData) do
        partVolumes[part] = part.Size.X * part.Size.Y * part.Size.Z
    end

    local totalVolume = 0
    for _, volume in pairs(partVolumes) do
        totalVolume += volume
    end

    for part, volume in pairs(partVolumes) do
        self._partFills[part] = 0
        self._partCapacities[part] = (volume / totalVolume) * totalCapacity
    end
end

function BlueprintEffect.new(instance)
    local self = setmetatable({}, BlueprintEffect)

    self.Instance = instance
    self._trove = Trove.new()

    self._partData = {}
    self._partFills = {}
    self._partCapacities = {}
    self._sortedCache = {}

    self:_addParts()
    self:_buildWeights(self.Instance:GetAttribute("ResourceStorage"))

    for part, _ in pairs(self._partData) do
        self:_updatePart(part)
    end

    self._trove:Add(function()
        self:_revertAll()
    end)

    local objectValue = self._trove:Construct(Instance, "ObjectValue")
    objectValue.Name = "ObjectValue"
    objectValue.Parent = instance

    local boolValue = self._trove:Construct(Instance, "BoolValue")
    boolValue.Name = "BoolValue"
    boolValue.Parent = instance

    self._trove:Connect(boolValue.Changed, function()
        self:Push(objectValue.Value, 1)
    end)

    return self
end

function BlueprintEffect:_push(partsList, amount)
    local amountRemaining = amount

    for _, pushingPart in ipairs(partsList) do
        local partCapacityUnused = (self._partCapacities[pushingPart] - self._partFills[pushingPart])
        local amountPushed = math.min(amountRemaining, partCapacityUnused)

        if amountPushed > 0 then
            self._partFills[pushingPart] += amountPushed
            self:_updatePart(pushingPart)
            amountRemaining -= amountPushed
        end

        if amountRemaining == 0 then
            return
        end
    end

    warn("[Blueprint Effect]", "Push exceeded capacity.")
end

function BlueprintEffect:Push(part, amount)
    local sortedParts = self:_getSorted(part)
    self:_push(sortedParts, amount)
end

function BlueprintEffect:Destroy()
    self._trove:Clean()
end

return BlueprintEffect