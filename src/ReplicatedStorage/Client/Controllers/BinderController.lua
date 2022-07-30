local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local BinderProvider = require(ReplicatedStorage.Common.BinderProvider)

--[=[
	@class BinderController
]=]
local BinderController = Knit.CreateController {
	Name = "BinderController";
}

BinderController._binderProvider = BinderProvider.new()

--[=[
	Searches for a particular Binder by its tag name.

	@param tagName string -- The tag to search for.
	@return Binder? -- The Binder, if found.
]=]
function BinderController:Get(tagName)
	return self._binderProvider:Get(tagName)
end

function BinderController:KnitInit()
	-- Load structure binders
	for _, instanceComponentModule in ipairs(ReplicatedStorage.Client.InstanceComponents.Structures) do
		self._binderProvider:Add(instanceComponentModule.Name, require(instanceComponentModule))
	end

	-- Load tool binders
	for _, instanceComponentModule in ipairs(ReplicatedStorage.Client.InstanceComponents.Tools) do
		self._binderProvider:Add(instanceComponentModule.Name, require(instanceComponentModule))
	end

	-- Load misc binders
	for _, instanceComponentModule in ipairs(ReplicatedStorage.Client.InstanceComponents.Misc) do
		self._binderProvider:Add(instanceComponentModule.Name, require(instanceComponentModule))
	end
end

function BinderController:KnitStart()
	self._binderProvider:Start()
end

return BinderController