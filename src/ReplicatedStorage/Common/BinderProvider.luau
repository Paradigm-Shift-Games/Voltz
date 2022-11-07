local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Binder = require(ReplicatedStorage.Packages.Binder)

local BinderProvider = {}
BinderProvider.__index = BinderProvider

function BinderProvider.new()
	local self = setmetatable({}, BinderProvider)
	self._binders = {}
	return self
end

function BinderProvider:Add(tagName, class)
	self._binders[tagName] = Binder.new(tagName, class)
end

function BinderProvider:Get(tagName)
	return self._binders[tagName]
end

function BinderProvider:Start()
	for _, binder in self._binders do
		binder:Start()
	end
end

function BinderProvider:Destroy()
	for _, binder in self._binders do
		binder:Destroy()
	end

	self._binders = {}
end

return BinderProvider