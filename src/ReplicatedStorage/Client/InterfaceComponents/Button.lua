local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages.Fusion)
local WrappedFusion = require(Packages.FusionUtils).Wrapped

--local UIComponents = script.Parent
--local ClientSrc = UIComponents.Parent
--local SharedInterfaceState = require(ClientSrc.SharedInterfaceState)

local New = WrappedFusion.New
local OnEvent = WrappedFusion.OnEvent
local Value = Fusion.Value

local function Button(props)
	-- Hovering/Pressing props
	local hovering = props.Hovering or Value(false)
	local pressing = props.Pressing or Value(false)
	local onPressDown = props.OnPressDown
	local onPressUp = props.OnPressUp

	props.Hovering = nil
	props.Pressing = nil
	props.OnPressDown = nil
	props.OnPressUp = nil

	-- Load default props
	props.BackgroundTransparency = props.BackgroundTransparency or 1
	props.Size = props.Size or UDim2.new(1, 0, 1, 0)

	-- Function injections
	props[OnEvent("Hover")] = function()
		hovering:set(true)
	end

	props[OnEvent("UnHover")] = function()
		task.spawn(function()
			--[[if SharedInterfaceState.InputType:get(false) == "Touch" then
				task.wait()
			end]]

			hovering:set(false)
			pressing:set(false)
		end)
	end

	props[OnEvent("PressDown")] = function(relativePosition)
		pressing:set(true)

		if onPressDown ~= nil then
			onPressDown(relativePosition)
		end
	end

	props[OnEvent("PressUp")] = function(relativePosition)
		if
			hovering:get(false)
			and pressing:get(false)
			and onPressUp ~= nil
			--and SharedState.InputType:get(false) ~= "Touch"
		then
			onPressUp(relativePosition)
		end

		pressing:set(false)
	end

	--[[props[OnEvent("Activated")] = function(relativePosition)
		if SharedState.InputType:get(false) == "Touch" and onPressUp ~= nil then
			onPressUp(relativePosition)
		end
	end]]

	return New("TextButton")(props)
end

return Button
