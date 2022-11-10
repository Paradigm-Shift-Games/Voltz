local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages.Knit)
local BinderProvider = require(Packages.BinderProvider)

--[=[
	@class BinderService
]=]
local BinderService = Knit.CreateService {
	Name = "BinderService";
	Client = {};
}

BinderService._binderProvider = BinderProvider.new()

--[=[
	Searches for a particular Binder by its tag name.

	@param tagName string -- The tag to search for.
	@return Binder? -- The Binder, if found.
]=]
function BinderService:Get(tagName)
	return self._binderProvider:Get(tagName)
end

function BinderService:KnitInit()
	-- Load structure binders
	for _, instanceComponentModule in ServerScriptService.InstanceComponents.Structures:GetChildren() do
		self._binderProvider:Add(instanceComponentModule.Name, require(instanceComponentModule))
	end

	-- Load tool binders
	for _, instanceComponentModule in ServerScriptService.InstanceComponents.Tools:GetChildren() do
		self._binderProvider:Add(instanceComponentModule.Name, require(instanceComponentModule))
	end

	-- Load misc binders
	for _, instanceComponentModule in ServerScriptService.InstanceComponents.Misc:GetChildren() do
		self._binderProvider:Add(instanceComponentModule.Name, require(instanceComponentModule))
	end
end

function BinderService:KnitStart()
	self._binderProvider:Start()
end

return BinderService