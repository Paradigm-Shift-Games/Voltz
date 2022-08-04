--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

--Public Types

export type Shape = "Box" | "Ball"

export type Zone = {
    --Public Fields
    shape : Shape;
    cFrame : CFrame;
    size : Vector3;
    overlapParams : OverlapParams;

    --"Private" Fields
    _within : { [Instance] : true };
    _signal : typeof(Signal.new());
}

--Private Constants

local defaultOverlapParams = OverlapParams.new()

--Public API--

local Zone = {}
Zone.__index = Zone

--Public Methods

--Creates a new Zone table
function Zone.new(arguments : {
    shape : Shape;
    cFrame : CFrame;
    size : Vector3;
    overlapParams : OverlapParams?;
}) : Zone

    local self = {} :: Zone

    self.shape = arguments.shape
    self.cFrame = arguments.cFrame
    self.size = arguments.size
    self.overlapParams = arguments.overlapParams or defaultOverlapParams

    self._within = {}
    self._signal = Signal.new()

    return setmetatable(self, Zone)
end

--Returns all instances that have entered and left the zone from the last poll
function Zone:Poll() : ({ Instance }, { Instance })
    --Get instances within the self
    local withinInstances : { Instance } =
        if self.shape == "Box" then
            workspace:GetPartBoundsInBox(self.cFrame, self.size, self.overlapParams)

        elseif self.shape == "Ball" then
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

    for instance, _ in pairs(self._within) do
        table.insert(exitingInstances, instance)
    end

    --Update self
    self._within = newWithin

    return enteringInstances, exitingInstances
end

--Fires the zone's signal with the entering and exiting instances
function Zone:PollSignal()
    local enteringInstances, exitingInstances = self:Poll()
    self._signal:Fire(enteringInstances, exitingInstances)
end

--Gets the zone's within instances
function Zone:GetWithin()
    return self._within
end

--Gets the signal that fires when the zone is polled
function Zone:GetSignal()
    return self._signal
end

return Zone