local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Silo = require(ReplicatedStorage.Packages.Silo)

--[=[
	The StatefulIncrementor passively increments a value over a state, without spawning extra threads or timers.
	An incrementation may be started, then collapsed or queried later.

	@class StatefulIncrementor
]=]
local StatefulIncrementor = {}
StatefulIncrementor.__index = StatefulIncrementor

--[=[
	Returns the current time.
	May be overriden per-incrementor or globally.

	@return number
]=]
function StatefulIncrementor.getTime()
	return workspace:GetServerTimeNow()
end

--[=[
	@return boolean -- Whether or not incrementation is in progress.
]=]
function StatefulIncrementor:IsIncrementing(): boolean
	return not not self.StartTime
end

--[=[
	@return boolean -- Whether or not incrementation has expired.
]=]
function StatefulIncrementor:IsExpired(): boolean
	if not self:IsIncrementing() then
		return false
	end

	return self:GetProgress() >= 1
end

--[=[
	Returns the raw progress of the incrementor as a value from 0 -> 1
	@param duration number? -- The duration to calculate over.
	@return number
]=]
function StatefulIncrementor:GetRawProgress(duration: number?): number
	if not self:IsIncrementing() then
		return 0
	end

	local timeElapsed = self.getTime() - self.StartTime
	return math.clamp(timeElapsed / assert(duration or self.Duration, "Cannot collapse. No duration is defined."), 0, 1)
end

--[=[
	Returns the current progress of the incrementor as a value from 0 -> 1
	@param duration number? -- The duration to calculate over.
	@return number
]=]
function StatefulIncrementor:GetProgress(duration: number?): number
	if not self:IsIncrementing() then
		return 0
	end

	-- Determine the alpha of the incrementation
	return TweenService:GetValue(
		self:GetRawProgress(duration),
		self.TweenStyle,
		self.TweenDirection
	)
end

--[=[
	Returns the amount that will currently be added when the incrementor is collapsed.
	@param duration number? -- The duration to calculate over.
	@return number
]=]
function StatefulIncrementor:GetValue(duration: number?): number
	return self:GetProgress(duration) * self.Amount
end

--[=[
	Returns the amount that will be left over and discarded after collapsing.
	@param duration number? -- The duration to calculate over.
	@return number
]=]
function StatefulIncrementor:GetRemainder(duration: number?): number
	return (1 - self:GetProgress(duration)) * self.Amount
end

--[=[
	Updates the duration of the incrementor.

	@param duration number -- The new duration.
]=]
function StatefulIncrementor:SetDuration(duration: number)
	self.Duration = duration
end

--[=[
	Returns the duration of the incrementor.

	@return number -- The remaining duration.
]=]
function StatefulIncrementor:GetDuration()
	local timeElapsed = self.getTime() - self.StartTime
	return math.max(0, timeElapsed - self.Duration)
end

--[=[
	Takes the amount to increment by and stores it to later be collapsed.
	Will accumulate over active incrementations. Collapse if desired.

	@param amount number -- The amount to increment by.
]=]
function StatefulIncrementor:Increment(amount: number)
	-- Update the amount and time of incrementation
	self.Amount += amount
	self.StartTime = self.getTime()
end

--[=[
	Takes the state and duration of the incrementation and collapses the state.
	@error Modifier -- Do not call this method directly when outside of a modifier.

	@param state Silo.State -- The current Silo state.
	@param duration number? -- The duration to collapse for (default is the duration of the incrementor).

	@return number -- The remainder of the collapse. Use this to accumulate left overs if desired.
]=]
function StatefulIncrementor:Collapse<S>(state: Silo.State<S>, duration: number?)
	-- Do nothing if not incrementing
	if not self:IsIncrementing() then
		return
	end

	-- Update the state & store the remainder
	self._increment(state, self:GetValue(duration))
	local remainder = self:GetRemainder(duration)

	-- Un-set incrementor amount/time
	self.Amount = 0
	self.StartTime = nil

	-- Return the remainder
	return remainder
end

--[=[
	Constructs a modifier which passive increments a value through state.

	@param increment Silo.Modifier<S> -- A Modifier function which increments a target by the given argument.
	@param duration number? -- The default duration an incrementor may take place over.
	@return StatefulIncrementor
]=]
function StatefulIncrementor.new<S>(increment: Silo.Modifier<S>, duration: number?)
	local self = setmetatable({
		Duration = duration;

		Amount = 0;
		Time = nil;
		TweenStyle = Enum.EasingStyle.Linear;
		TweenDirection = Enum.EasingDirection.Out;
		_increment = increment;
	}, StatefulIncrementor)

	return self
end

return StatefulIncrementor