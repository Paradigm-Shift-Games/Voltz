-- Imports
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Player = Players.LocalPlayer

local Knit = require(Packages.Knit)
local Symbol = require(Packages.Symbol)

--[=[
	@type UnmountKey any
	@within InterfaceController

	A key, specifically created using `newproxy()`, that can be used to unmount
	an interface which was previously mounted using `Mount()`.
]=]
export type UnmountKey = any

--[=[
	@class InterfaceController
	@client
]=]
local InterfaceController = Knit.CreateController({
	Name = "InterfaceController",
})

--[=[
	@prop PlayerGui PlayerGui
	@within InterfaceController
	@readonly

	Reference to the local player's `PlayerGui` object.
]=]

--[=[
	@prop GameGui ScreenGui
	@within InterfaceController
	@readonly

	Reference to the main ScreenGui object which contains any interfaces mounted
	without explicitly providing a parent object to mount it to.
]=]
function InterfaceController:KnitInit()
	-- Disable reset player gui on spawn
	StarterGui.ResetPlayerGuiOnSpawn = false

	-- Setup private variables
	self._interfaceToUnmountKey = {} :: { [Instance]: UnmountKey }
	self._unmountKeyToInterface = {} :: { [UnmountKey]: Instance }
	self._unmountKeyToParentGui = {} :: { [UnmountKey]: Instance }
	self._unmountFunctions = {} :: { [UnmountKey]: () -> (...any) }

	-- Setup public variables
	local playerGui = Player:WaitForChild("PlayerGui")
	local gameGui = Instance.new("ScreenGui")
	gameGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gameGui.Name = "GameGui"
	gameGui.Parent = playerGui

	-- Expose public variables
	self.PlayerGui = playerGui
	self.GameGui = gameGui
end

--[=[
	Mounts an interface to the supplied parent. If no parent is supplied, then
	the interface will be mounted to `GameGui`.

	To mount interfaces to a BasePart, you can supply either a GuiBase, or a
	SurfaceGui for the `interface` argument. You should then supply a BasePart
	for the `parent` argument. If you supply a GuiBase instead of a SurfaceGui,
	then the interface will be mounted to a new SurfaceGui.

	If the interface is already mounted, then this function will return the
	`UnmountKey` that was previously returned by `Mount()`.
]=]
function InterfaceController:Mount(interface: GuiBase | GuiBase2d, parent: Instance?): UnmountKey
	-- Check if interface is already mounted, if it is then return the unmount key
	local storedUnmountKey = self._interfaceToUnmountKey[interface]
	if storedUnmountKey then
		return storedUnmountKey :: UnmountKey
	end

	-- Get/create parent gui if it doesn't exist
	local parentGui

	if parent ~= nil then
		if parent:IsA("BasePart") or parent:IsDescendantOf(workspace) then
			parentGui = if interface:IsA("SurfaceGui") then interface else Instance.new("SurfaceGui")
			parentGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			parentGui.Adornee = parent
			parentGui.Parent = self.PlayerGui
		else
			parentGui = interface
			parentGui.Parent = parent
		end
	else
		parentGui = interface

		if interface:IsA("ScreenGui") then
			parentGui.Parent = self.PlayerGui
		else
			parentGui.Parent = self.GameGui
		end
	end

	-- Mount the interface to the parent gui if we created a new one
	if parentGui ~= interface then
		interface.Parent = parentGui
	end

	-- Store the unmount key and function
	local unmountKey = Symbol("UnmountKey")

	self._unmountKeyToParentGui[unmountKey] = interface
	self._interfaceToUnmountKey[interface] = unmountKey
	self._unmountFunctions[interface] = function()
		self._unmountFunctions[interface] = nil
		parentGui:Destroy()
	end

	-- Return the stored unmount key
	return unmountKey :: UnmountKey
end

--[=[
	Unmounts an interface that was previously mounted using `Mount()`. The
	unmount process will be performed immediately, and will result in the
	destruction of the interface. If you explicitly supplied a `parent` argument
	to `Mount()`, the `parent` object will not be destroyed.

	Returns a boolean indicating whether or not the interface was successfully
	unmounted. If an error occurs, then the error message will be returned after
	the boolean.
]=]
function InterfaceController:Unmount(unmountKey: UnmountKey): (boolean, ...any)
	-- Get the interface to unmount
	local mountedParentGui = self._unmountKeyToParentGui[unmountKey]
	local mountedInterface = self._unmountKeyToInterface[unmountKey]
	self._unmountKeyToParentGui[unmountKey] = nil
	self._unmountKeyToInterface[unmountKey] = nil

	-- Cleanup extra references
	if mountedInterface ~= nil then
		self._interfaceToUnmountKey[mountedInterface] = nil
	end

	-- Guard
	if mountedParentGui == nil then return false end

	-- Get the unmount function
	local unmountFunction = self._unmountFunctions[mountedParentGui]
	self._unmountFunctions[mountedParentGui] = nil

	-- Guard
	if unmountFunction == nil then return false end

	-- Unmount the interface
	return pcall(unmountFunction)
end

return InterfaceController
