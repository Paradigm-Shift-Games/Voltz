--!strict

--Public Types

export type Shape_t = number

export type Zone_t = {
    --Public Fields
    shape : Shape_t;
    cFrame : CFrame;
    size : Vector3;
    overlapParams : OverlapParams;

    --Private Fields
    _within : { [Instance] : true };
}

--Private Constants

local defaultOverlapParams = OverlapParams.new()

--Public API--

local Zone = {}
Zone.__index = Zone

--Public Properties

Zone.Shapes = {
    Box = 1;
    Sphere = 2;
}

--Public Methods

--Creates a new Zone table
function Zone.new(arguments : {
    shape : Shape_t;
    cFrame : CFrame;
    size : Vector3;
    overlapParams : OverlapParams?;
}) : Zone_t

    local self = {} :: Zone_t

    self.cFrame = arguments.cFrame
    self.size = arguments.size
    self.overlapParams = arguments.overlapParams or defaultOverlapParams

    self._within = {}

    return setmetatable(self, Zone)
end

--Returns all instances that have entered and left the zone from the last poll
function Zone:Poll() : ({ Instance }, { Instance })
    --Get instances within the self
    local withinInstances : { Instance } =
        if self.shape == Zone.Shapes.Box then
            workspace:GetPartBoundsInBox(self.cFrame, self.size, self.overlapParams)

        elseif self.shape == Zone.Shapes.Sphere then
            workspace:GetPartBoundsInRadius(self.cFrame.Position, math.max(self.size.X, self.size.Y, self.size.Z), self.overlapParams) --This is the same behavior as setting the size of a ball part

        else
            nil

    --Assert potential errors
    assert(withinInstances, "withinInstances is nil, zone does not have valid shape.")

    --Get entering and exiting instances
    local newWithin : { [Instance] : true } = {}

    local enteringInstances : { Instance } = {}
    local exitingInstances : { Instance } = {}

    for _, instance in ipairs(withinInstances) do
        newWithin[instance] = true

        if not self._within[instance] then
            table.insert(enteringInstances, instance)
        end

        self._within[instance] = nil
    end

    for instance in pairs(self._within) do
        table.insert(exitingInstances, instance)
    end

    --Update self
    self._within = newWithin

    return enteringInstances, exitingInstances
end

local zone = Zone.new({
    shape = Zone.Shapes.Box;
    cFrame = CFrame.new(0, 0, 0);
    size = Vector3.new(100, 100, 100);
    -- overlapParams = OverlapParams.new();
})

game:GetService("RunService").Heartbeat:Connect(function(delatime)
    local enteringInstances, exitingInstances = zone:Poll()

    if #enteringInstances > 0 then
        for _, instance in ipairs(enteringInstances) do
            print("Entering: " .. instance.Name)
        end
    end

    if #exitingInstances > 0 then
        for _, instance in ipairs(exitingInstances) do
            print("Exiting: " .. instance.Name)
        end
    end
end)

return Zone