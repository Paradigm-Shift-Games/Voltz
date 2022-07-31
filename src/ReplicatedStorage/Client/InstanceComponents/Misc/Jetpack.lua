local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Comm = require(ReplicatedStorage.Packages.Comm)
local JetpackState = require(ReplicatedStorage.Common.Util.JetpackState)

local Jetpack = {}
Jetpack.__index = Jetpack

function Jetpack.new(instance)
	local clientComm = Comm.ClientComm.new(instance, false, "Jetpack")
	local self = setmetatable({}, Jetpack)

	self.Instance = instance
	self._comm = clientComm
	self._trove = Trove.new()

	-- Set owning player
	self._owner = Players:GetPlayerFromCharacter(instance.Parent)
	instance.AncestryChanged:Connect(function()
		self._owner = Players:GetPlayerFromCharacter(instance.Parent)
	end)
	if not self:IsOwner() then
		return self
	end

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

	-- Create server object
	self._serverObject = clientComm:BuildObject()

	-- Subscribe to attribute changes
	self._trove:Connect(instance:GetAttributeChangedSignal("Boosting"), function()
		self._state._silo:Dispatch(self._state._silo.Actions.SetBoosting(instance:GetAttribute("Boosting")))
	end)
	self._trove:Connect(instance:GetAttributeChangedSignal("Fuel"), function()
		self._state._silo:Dispatch(self._state._silo.Actions.SetFuel(instance:GetAttribute("Fuel")))
	end)
	self._trove:Connect(instance:GetAttributeChangedSignal("Capacity"), function()
		self._state._silo:Dispatch(self._state._silo.Actions.SetCapacity(instance:GetAttribute("Capacity")))
	end)
	self._trove:Connect(instance:GetAttributeChangedSignal("FillRate"), function()
		self._state._silo:Dispatch(self._state._silo.Actions.SetFillRate(instance:GetAttribute("FillRate")))
	end)
	self._trove:Connect(instance:GetAttributeChangedSignal("BurnRate"), function()
		self._state._silo:Dispatch(self._state._silo.Actions.SetBurnRate(instance:GetAttribute("BurnRate")))
	end)

	-- Boost event
	self.Boosting = self._state.Boosting

	-- Jetpack physics
	local vectorForce = instance:FindFirstChild("Thrust")
	self._trove:Connect(self.Boosting, function(boosting)
		print("Boosting", boosting, self._state:GetState(), self._state:GetState().Fuel)

		vectorForce.Force = if not boosting then Vector3.new() else instance.AssemblyMass * workspace.Gravity * Vector3.yAxis + instance:GetAttribute("ThrustForce") * Vector3.yAxis
	end)

	-- User input
	ContextActionService:BindAction("Jetpack", function(actionName: string, userInputState: Enum.UserInputState)
		task.spawn(function()
			local character = instance.Parent
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			-- Boost if hitting space and the humanoid is free falling
			if userInputState == Enum.UserInputState.Begin and humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
				self:StartBoosting()
			elseif userInputState == Enum.UserInputState.End then
				self:StopBoosting()
			end
		end)
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.Space)
	return self
end

function Jetpack:IsOwner()
	return not Players.LocalPlayer or Players.LocalPlayer == self._owner
end

function Jetpack:StartBoosting()
	if not self:IsOwner() then
		return
	end
	if self._state:GetState().Boosting then
		return
	end
	self._state._silo:Dispatch(self._state._silo.Actions.SetBoosting(true))
	return self._serverObject:StartBoosting()
end
function Jetpack:StopBoosting()
	if not self:IsOwner() then
		return
	end
	if not self._state:GetState().Boosting then
		return
	end
	self._state._silo:Dispatch(self._state._silo.Actions.SetBoosting(false))
	return self._serverObject:StopBoosting()
end

function Jetpack:Destroy()
	self._trove:Clean()
end

return Jetpack