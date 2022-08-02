local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Comm = require(ReplicatedStorage.Packages.Comm)
local JetpackState = require(ReplicatedStorage.Common.Util.JetpackState)

--[=[
	@class Jetpack
]=]
local Jetpack = {}
Jetpack.__index = Jetpack

--[=[
	Constructs a new Jetpack component.
	@param instance Instance
]=]
function Jetpack.new(instance)
	local serverComm = Comm.ServerComm.new(instance, "Jetpack")
	local self = setmetatable({}, Jetpack)

	self.Instance = instance
	self._comm = serverComm
	self._trove = Trove.new()

	-- Set owning player
	self._owner = Players:GetPlayerFromCharacter(instance.Parent)
	instance.AncestryChanged:Connect(function()
		self._owner = Players:GetPlayerFromCharacter(instance.Parent)
	end)

	-- Create state
	self._state = JetpackState.new({
		Boosting = instance:GetAttribute("Boosting");

		Fuel = instance:GetAttribute("Fuel");
		Capacity = instance:GetAttribute("Capacity");
		FillRate = instance:GetAttribute("FillRate");
		BurnRate = instance:GetAttribute("BurnRate");
	})

	-- Add state and comm to trove
	self._trove:Add(self._state)
	self._trove:Add(self._comm)

	-- Subscribe to attribute changes
	self._trove:Connect(instance:GetAttributeChangedSignal("Boosting"), function()
		self._state:Dispatch("SetBoosting", instance:GetAttribute("Boosting"))
	end)
	self._trove:Connect(instance:GetAttributeChangedSignal("Fuel"), function()
		self:SetFuel(instance:GetAttribute("Fuel"))
	end)
	self._trove:Connect(instance:GetAttributeChangedSignal("Capacity"), function()
		self:SetCapacity(instance:GetAttribute("Capacity"))
	end)
	self._trove:Connect(instance:GetAttributeChangedSignal("FillRate"), function()
		self:SetFillRate(instance:GetAttribute("FillRate"))
	end)
	self._trove:Connect(instance:GetAttributeChangedSignal("BurnRate"), function()
		self:SetBurnRate(instance:GetAttribute("BurnRate"))
	end)

	-- Notify client about state events
	self._trove:Add(self._state._silo:Subscribe(function(newState, oldState)
		local function isNan(value)
			return value ~= value
		end

		-- Set attributes for any values which have changed
		for index, value in pairs(newState) do
			local oldValue = oldState[index]
			if value ~= oldValue or isNan(value) ~= isNan(oldValue) then
				instance:SetAttribute(index, value)
			end
		end
	end))

	-- Wrap boost methods
	serverComm:WrapMethod(self, "StartBoosting")
	serverComm:WrapMethod(self, "StopBoosting")

	-- Boost event
	self.Boosting = self._state.Boosting

	-- Create thrust force & attachment
	local thrustAttachment = Instance.new("Attachment")
	thrustAttachment.Name = "ThrustAttachment"

	local thrust = Instance.new("LinearVelocity")
	thrust.Name = "Thrust"
	thrust.RelativeTo = Enum.ActuatorRelativeTo.World
	thrust.Attachment0 = thrustAttachment
	thrust.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
	thrust.LineDirection = Vector3.yAxis
	thrust.MaxForce = 0
	thrust.LineVelocity = instance:GetAttribute("MaxThrustSpeed")

	thrustAttachment.Parent = instance
	thrust.Parent = instance

	-- Add thrust force & attachment to Trove
	self._trove:Add(thrustAttachment)
	self._trove:Add(thrust)

	-- Jetpack physics
	self._trove:Connect(self.Boosting, function(boosting)
		print("Boosting", boosting, self._state:GetState(), self._state:GetState().Fuel)

		thrust.MaxForce = if not boosting then 0 else instance.AssemblyMass * (workspace.Gravity + instance:GetAttribute("ThrustAcceleration"))
	end)

	-- Sync MaxThrustSpeed attribute to thrust velocity
	self._trove:Connect(instance:GetAttributeChangedSignal("MaxThrustSpeed"), function()
		thrust.LineVelocity = instance:GetAttribute("MaxThrustSpeed")
	end)

	return self
end

--[=[
	Returns whether or not the specific player is the owner of this jetpack.

	@server
	@param player Player? -- The player to check. If nil, always returns true.
	@return boolean
]=]
function Jetpack:IsOwner(player: Player?)
	return not player or player == self._owner
end

--[=[
	Causes the jetpack to begin boosting.

	@server
	@param player Player? -- The player making the request, or nil if server-authored.
]=]
function Jetpack:StartBoosting(player: Player?)
	if not self:IsOwner(player) then
		return
	end
	if self._state:GetState().Boosting then
		return
	end
	self._state:Dispatch("SetBoosting", true)
end
--[=[
	Causes the jetpack to cease boosting.

	@server
	@param player Player? -- The player making the request, or nil if server-authored.
]=]
function Jetpack:StopBoosting(player: Player?)
	if not self:IsOwner(player) then
		return
	end
	if not self._state:GetState().Boosting then
		return
	end
	self._state:Dispatch("SetBoosting", false)
end

--[=[
	Updates the jetpack's current fuel
	@param fuel number -- A number from `0` - `1`.
	@server
]=]
function Jetpack:SetFuel(fuel: number)
	self._state:Dispatch("SetFuel", fuel)
end

--[=[
	Updates the jetpack's capacity
	@param capacity number
	@server
]=]
function Jetpack:SetCapacity(capacity: number)
	self._state:Dispatch("SetCapacity", capacity)
end

--[=[
	Updates the rate at which the jetpack refills fuel when not boosting.
	@param fillRate number
	@server
]=]
function Jetpack:SetFillRate(fillRate: number)
	self._state:Dispatch("SetFillRate", fillRate)
end

--[=[
	Updates the rate at which the jetpack consumes fuel when boosting.
	@param burnRate number
	@server
]=]
function Jetpack:SetBurnRate(burnRate: number)
	self._state:Dispatch("SetBurnRate", burnRate)
end

--[=[
	Calculates the jetpack's current fuel percentage.
	@return number -- The fuel percentage from `0` - `1`.
]=]
function Jetpack:GetFuelPercentage()
	return self._state:CalculateFuelPercentage()
end

--[=[
	Calculates the jetpack's current fuel.
	@return number -- The amount of fuel from `0` to its total capacity.
]=]
function Jetpack:GetFuel()
	return self:GetFuelPercentage() * self._state:GetState().Capacity
end

--[=[
	Destroys the component.
]=]
function Jetpack:Destroy()
	self._trove:Clean()
end

return Jetpack