local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local BinderProvider = require(ReplicatedStorage.Common.BinderProvider)

local BinderController = Knit.CreateController {
	Name = "BinderController";
}

BinderController._binderProvider = BinderProvider.new()

function BinderController:Get(tagName)
	return self._binderProvider:Get(tagName)
end

function BinderController:KnitInit()
	for _, instanceComponentModule in ipairs(ReplicatedStorage.Client.InstanceComponents.Structures) do
		self._binderProvider:Add(instanceComponentModule.Name, require(instanceComponentModule))
	end

	for _, instanceComponentModule in ipairs(ReplicatedStorage.Client.InstanceComponents.Tools) do
		self._binderProvider:Add(instanceComponentModule.Name, require(instanceComponentModule))
	end

	for _, instanceComponentModule in ipairs(ReplicatedStorage.Client.InstanceComponents.Misc) do
		self._binderProvider:Add(instanceComponentModule.Name, require(instanceComponentModule))
	end
end

function BinderController:KnitStart()
	self._binderProvider:Start()
end

return BinderController