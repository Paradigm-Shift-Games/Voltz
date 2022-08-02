local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Trove = require(Packages.Trove)
local Fusion = require(Packages.Fusion)
local WrappedFusion = require(Packages.FusionUtils).Wrapped

local UIComponents = script.Parent
local ToolbarItem = require(UIComponents.Toolbar.ToolbarItem)

local New = WrappedFusion.New
local Statify = WrappedFusion.Statify
local Value = Fusion.Value
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForValues = Fusion.ForValues
local Cleanup = Fusion.Cleanup

local KEY_CODES = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.KeyCode.Zero,
}

local function keyCodeToString(keyCode)
	if keyCode == "" then
		return ""
	elseif keyCode.Value <= 126 and keyCode.Value >= 34 then
		return string.char(keyCode.Value)
	else
		return keyCode.Name
	end
end

local function Toolbar(props)
	-- Property-derived states/values
	local tools = Statify(props.Tools or {})

	-- Component-specific states/values
	local trove = Trove.new()

	local instancesPendingDeletion = Value({})
	local instancesLoaded = Value({})
	local selectedInstance = Value(nil)
	local selectedKeyCode = 0
	local toolCount = 0


	-- Connect to events
	trove:Connect(UserInputService.InputBegan, function(input, gameProcessed)
		-- Get input data
		local keyCode = input.KeyCode
		local keyCodeString = keyCodeToString(keyCode)
		local isNumber, keyCodeNumber = pcall(function() return tonumber(keyCodeString) end)

		-- Guard
		if gameProcessed then return end
		if not isNumber then return end
		if type(keyCodeNumber) ~= "number" then return end
		if keyCodeNumber > toolCount then return end
		if keyCodeNumber == 0 and toolCount < 10 then return end
		if keyCodeNumber < 0 then return end

		-- Process input
		local currentInstancesLoaded = instancesLoaded:get(false)

		if selectedKeyCode == keyCodeNumber then
			selectedKeyCode = nil
			selectedInstance:set(nil)
		elseif currentInstancesLoaded[keyCodeNumber] ~= nil then
			selectedKeyCode = keyCodeNumber
			selectedInstance:set(currentInstancesLoaded[keyCodeNumber])
		end
	end)


	-- Create Toolbar
	return New "Frame" {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,

		[Cleanup] = function()
			trove:Destroy()
		end,

		[Children] = {
			New "UIListLayout" {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},

			instancesPendingDeletion,

			ForValues(tools, function(toolData)
				-- Get tool data
				local toolName = Statify(toolData.ToolName)
				local selected = toolData.Selected or Value(false)

				-- Setup values
				local instance = Value(nil)
				local index = Computed(function()
					-- Get current instance
					local currentInstance = instance:get()

					-- Guard
					if currentInstance == nil then return nil end

					-- Get current index
					for i, loadedInstance in pairs(instancesLoaded:get()) do
						if loadedInstance == currentInstance then
							return i
						end
					end

					return nil
				end)

				local keyCode = Computed(function()
					-- Get current index
					local currentIndex = index:get()

					-- Guard
					if currentIndex == nil then return nil end

					-- Get current key code
					return KEY_CODES[currentIndex]
				end)

				local inputName = Computed(function()
					-- Get current key code
					local currentKeyCode = keyCode:get()

					-- Guard
					if currentKeyCode == nil then return "" end

					-- Return key code string
					return keyCodeToString(currentKeyCode)
				end)

				-- Setup meta data
				local meta = {
					Visible = Value(true),
					Selected = selected,
					Index = index,
					LayoutOrderOverride = Value(nil)
				}

				-- Create tool bar item
				local layoutOrder = Computed(function()
					return meta.LayoutOrderOverride:get() or index:get() or 10000
				end)

				local computedVisibility = Computed(function()
					return meta.Visible:get() and index:get() ~= nil
				end)

				local computedSelected = Computed(function()
					-- Get selected value
					local isSelected = selectedInstance:get() == instance:get() and instance:get() ~= nil

					-- Replicate selected value externally (this is probably cursed)
					selected:set(isSelected)

					-- Return selected value
					return isSelected
				end)

				local toolbarItem = ToolbarItem({
					ToolName = toolName,
					InputName = inputName,

					LayoutOrder = layoutOrder,
					Visible = computedVisibility,
					Selected = computedSelected,

					OnPressUp = function()
						if computedSelected:get(false) then
							selectedInstance:set(nil)
						else
							selectedInstance:set(instance:get(false))
						end
					end,
				})

				-- Set/store instance values
				local currentInstancesLoaded = instancesLoaded:get(false)
				local newInstancesLoaded = table.clone(currentInstancesLoaded)
				table.insert(newInstancesLoaded, toolbarItem)
				instancesLoaded:set(newInstancesLoaded)
				instance:set(toolbarItem)

				-- Return instance and meta data
				return toolbarItem, meta
			end, function(instance, meta)
				-- Cleanup
				if meta.Selected:get(false) then
					selectedInstance:set(nil)
				end

				meta.Visible:set(false)

				-- Update instance-dependent values
				meta.LayoutOrderOverride:set(meta.Index:get())

				local currentInstancesLoaded = instancesLoaded:get(false)
				local newInstancesLoaded = table.clone(currentInstancesLoaded)
				local currentInstancesPendingDeletion = instancesPendingDeletion:get(false)
				local newInstancesPendingDeletion = table.clone(currentInstancesPendingDeletion)

				for i = #newInstancesLoaded, 1, -1 do
					local loadedInstance = newInstancesLoaded[i]

					if loadedInstance == instance then
						table.remove(newInstancesLoaded, i)
					end
				end

				table.insert(newInstancesPendingDeletion, instance)

				instancesLoaded:set(newInstancesLoaded)
				instancesPendingDeletion:set(newInstancesPendingDeletion)

				-- Delete instance after a short delay
				task.delay(1, function()
					newInstancesPendingDeletion = table.clone(instancesPendingDeletion:get())

					for i = #newInstancesPendingDeletion, 1, -1 do
						local instancePendingDeletion = newInstancesPendingDeletion[i]

						if instancePendingDeletion == instance then
							table.remove(newInstancesPendingDeletion, i)
						end
					end

					instancesPendingDeletion:set(newInstancesPendingDeletion)
					instance:Destroy()
				end)
			end),
		},
	}
end

return Toolbar