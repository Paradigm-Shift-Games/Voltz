local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Silo = require(ReplicatedStorage.Packages.Silo)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Promise = require(ReplicatedStorage.Packages.Promise)
local StatefulIncrementor = require(ReplicatedStorage.Common.Util.StatefulIncrementor)

--[=[
	@class JetpackState
]=]
local JetpackState = {
	Default = {
		Boosting = false; -- Whether or not the jetpack is boosting

		Fuel = 1; -- A value from 0 - 1 representing the current fuel percentage
		Capacity = 100; -- A value representing the jetpack's fuel capacity
		BurnRate = 0.1; -- The rate at which fuel will be burned
		FillRate = 1; -- The rate at which fuel will be refilled
	};
}
JetpackState.Default.__index = JetpackState.Default
JetpackState.__index = JetpackState

function JetpackState.new<S>(state: S)
	local jetpackState = setmetatable({
		_trove = Trove.new();
		_silo = Silo.new(setmetatable(table.clone(state), JetpackState.Default) :: any, {
			CollapseIncrementor = function(self, incrementor)
				incrementor:Collapse(self)
			end;

			SetFuel = function(self, fuel: amount)
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

	local boostPromise

	jetpackState._trove:Add(jetpackState.Boosting)
	jetpackState._trove:Add(jetpackState._silo:Subscribe(function(self, oldState)
		-- Determine target fuel and update rate
		local targetFuel = if self.Boosting then 0 else 1
		local updateRate = if self.Boosting then self.BurnRate else self.FillRate

		-- If the fuel incrementor is active, collapse it
		local fuelIncrementor = jetpackState._fuelIncrementor
		if fuelIncrementor:IsIncrementing() then
			jetpackState._silo:Dispatch(jetpackState._silo.Actions.CollapseIncrementor(fuelIncrementor))
			return
		end

		-- Set the new duration, and begin burning/refilling fuel
		local duration = math.abs(targetFuel - self.Fuel) * self.Capacity / updateRate
		fuelIncrementor:SetDuration(duration)
		fuelIncrementor:Increment(math.sign(targetFuel - self.Fuel) * math.clamp(math.abs(targetFuel - self.Fuel), 0, 1))

		-- Collapse if expired
		if fuelIncrementor:IsExpired() then
			jetpackState._silo:Dispatch(jetpackState._silo.Actions.CollapseIncrementor(fuelIncrementor))
			return
		end

		-- Fire the Boosting event
		jetpackState.Boosting:Fire(self.Boosting)

		if boostPromise then
			boostPromise:cancel()
			boostPromise = nil
		end
		if self.Boosting then
			boostPromise = Promise.delay(duration)
			boostPromise:andThenCall(function()
				jetpackState._silo:Dispatch(jetpackState._silo.Actions.SetBoosting(false))
				boostPromise = nil
			end)
		end
	end))

	jetpackState._trove:Add(function()
		if boostPromise then
			boostPromise:cancel()
			boostPromise = nil
		end
	end)

	return jetpackState
end

function JetpackState:GetDuration()
	return self._fuelIncrementor:GetDuration()
end
function JetpackState:CalculateFuelPercentage()
	return self._silo:GetState().Fuel + self._fuelIncrementor:GetValue()
end
function JetpackState:GetState()
	return self._silo:GetState()
end

function JetpackState:Destroy()
	self._trove:Clean()
end

return JetpackState