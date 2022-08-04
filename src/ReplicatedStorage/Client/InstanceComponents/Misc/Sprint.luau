local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Comm = require(ReplicatedStorage.Packages.Comm)

local Sprint = {}
Sprint.__index = Sprint

function Sprint.new(character: Model)
	local self = setmetatable({}, Sprint)

	self._trove = Trove.new()
	self._comm = self._trove:Construct(Comm.ClientComm, character, false, "Sprint")
	self._serverObject = self._comm:BuildObject()
	self._owner = Players:GetPlayerFromCharacter(character)
	self.Instance = character

	if not self:IsOwner() then
		return self
	end

	ContextActionService:BindAction("Sprint",
		function(actionName: string, userInputState: Enum.UserInputState)
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")

			if userInputState == Enum.UserInputState.Begin and humanoid then
				self:StartSprinting()
			elseif userInputState == Enum.UserInputState.End then
				self:StopSprinting()
			end

			return Enum.ContextActionResult.Pass
		end,
	false, Enum.KeyCode.LeftShift)

	return self
end

function Sprint:IsOwner()
	return Players.LocalPlayer == self._owner
end

function Sprint:StartSprinting()
	if not self:IsOwner() then return end
	return self._serverObject:StartSprinting()
end

function Sprint:StopSprinting()
	if not self:IsOwner() then return end
	return self._serverObject:StopSprinting()
end

function Sprint:Destroy()
	self._trove:Clean()
end

return Sprint