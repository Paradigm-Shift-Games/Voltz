local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Silo = require(ReplicatedStorage.Packages.Silo)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Promise = require(ReplicatedStorage.Packages.Promise)
local StatefulIncrementor = require(ReplicatedStorage.Common.Util.StatefulIncrementor)

--[=[
	@within JetpackState
	@interface State
	.Boosting boolean -- Whether or not the jetpack is boosting
	.Fuel number -- A value from `0` - `1` representing the current fuel percentage
	.Capacity number -- A value representing the jetpack's fuel capacity
	.BurnRate number -- The rate at which fuel will be burned
	.FillRate number  -- The rate at which fuel will be refilled
]=]

--[=[
	@class JetpackState
]=]
local JetpackState = {
	Default = {
		Boosting = false;

		Fuel = 1;
		Capacity = 100;
		BurnRate = 0.1;
		FillRate = 1;
	};
}
JetpackState.Default.__index = JetpackState.Default
JetpackState.__index = JetpackState

--[=[
	Constructs a new JetpackState
	@param state State
	@return JetpackState
]=]
function JetpackState.new<S>(state: S)
	local self = setmetatable({
		_trove = Trove.new();
		_silo = Silo.new(setmetatable(table.clone(state), JetpackState.Default) :: any, {
			_collapseIncrementor = function(self, incrementor)
				incrementor:Collapse(self)
			end;

			SetFuel = function(self, fuel: number)
				self.Fuel = fuel
			end;
			SetBoosting = function(self, boosting: boolean)
				self.Boosting = boosting
			end;
			SetCapacity = function(self, capacity: number)
				self.Capacity = capacity
			end;
			SetFillRate = function(self, fillRate: number)
				self.FillRate = fillRate
			end;
			SetBurnRate = function(self, burnRate: number)
				self.BurnRate = burnRate
			end;
		} :: any);
		_fuelIncrementor = StatefulIncrementor.new(function(self, amount)
			local newFuel = math.clamp(self.Fuel + amount, 0, 1)
			if self.Fuel ~= newFuel then
				self.Fuel = newFuel
			end
		end);

		Boosting = Signal.new();
	}, JetpackState)

	-- Add the Boosting signal to the trove
	self._trove:Add(self.Boosting)

	-- Handle when any state update occurs so we can enforce fuel usage
	local boostPromise
	self._trove:Add(self._silo:Subscribe(function(newState, oldState)
		-- Determine target fuel and update rate
		local targetFuel = if newState.Boosting then 0 else 1
		local updateRate = if newState.Boosting then newState.BurnRate else newState.FillRate

		-- If the fuel incrementor is active, collapse it
		local fuelIncrementor = self._fuelIncrementor
		if fuelIncrementor:IsIncrementing() then
			self:Dispatch("_collapseIncrementor", fuelIncrementor)
			return
		end

		-- Set the new duration, and begin burning/refilling fuel
		local duration = math.abs(targetFuel - newState.Fuel) * newState.Capacity / updateRate
		fuelIncrementor:SetDuration(duration)
		fuelIncrementor:Increment(math.sign(targetFuel - newState.Fuel) * math.clamp(math.abs(targetFuel - newState.Fuel), 0, 1))

		-- If the fuel incrementor has expired, collapse immediately
		if fuelIncrementor:IsExpired() then
			self:Dispatch("_collapseIncrementor", fuelIncrementor)
			return
		end

		-- Fire the Boosting event
		self.Boosting:Fire(newState.Boosting)

		-- If we already have a promise to stop the jetpack boost, cancel it
		if boostPromise then
			boostPromise:cancel()
			boostPromise = nil
		end

		-- If we are boosting, delay until the fuel will be exhausted and then stop boosting
		if newState.Boosting then
			boostPromise = Promise.delay(duration)
			boostPromise:andThenCall(function()
				self:Dispatch("SetBoosting", false)
				boostPromise = nil
			end)
		end
	end))

	self._trove:Add(function()
		if boostPromise then
			boostPromise:cancel()
			boostPromise = nil
		end
	end)

	return self
end

--[=[
	Dispatches an action onto the internal silo.

	@param actionName string -- The name of the action to perfom
	@param input any -- The input to provide to the action
]=]
function JetpackState:Dispatch<S>(actionName: string, input: any)
	self._silo:Dispatch(self._silo.Actions[actionName](input))
end

--[=[
	@return number -- The duration remaining on the fuel incrementor.
]=]
function JetpackState:GetDuration()
	return self._fuelIncrementor:GetDuration()
end

--[=[
	Calculates the jetpack's fuel percentage.
	@return number -- The current fuel percentage `0` - `1`.
]=]
function JetpackState:CalculateFuelPercentage()
	return self._silo:GetState().Fuel + self._fuelIncrementor:GetValue()
end

--[=[
	@return State
]=]
function JetpackState:GetState()
	return self._silo:GetState()
end

--[=[
	Destroys the object.
]=]
function JetpackState:Destroy()
	self._trove:Clean()
end

return JetpackState