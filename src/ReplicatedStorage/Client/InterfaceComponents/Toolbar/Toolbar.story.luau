local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local StoryTaskBar = require(Packages.StoryTaskBar)
local Fusion = require(Packages.Fusion)

local Toolbar = require(script.Parent)

local New = Fusion.New
local Value = Fusion.Value
local Spring = Fusion.Spring
local Computed = Fusion.Computed

local story = StoryTaskBar()

local randomToolNames = {
	"Portafab",
	"Rocket Launcher",
	"SMG",
	"Assault Rifle",
	"Shotgun",
	"Sniper Rifle",
	"Minigun",
	"Laser Drill",
	"Hand Mortar",
	"Laser Strike",
}

story:setBackgroundSize(UDim2.fromScale(0.9, 1))

story:setConstructor(function(background)
	local props = {
		SelectedIndex = Value(nil),
		Tools = Value({
			{
				ToolName = Value("Portafab"),
				Selected = Value(false),
			}
		})
	}

	local meta = {
		Bottom = Value(false)
	}

	local container = New "Frame" {
		Size = UDim2.fromScale(1, 0.06),
		AnchorPoint = Spring(Computed(function()
			if meta.Bottom:get() then
				return Vector2.new(0.5, 1)
			else
				return Vector2.new(0.5, 0.5)
			end
		end), 10, 0.9),
		Position = Spring(Computed(function()
			if meta.Bottom:get() then
				return UDim2.fromScale(0.5, 0.925)
			else
				return UDim2.fromScale(0.5, 0.5)
			end
		end), 10, 0.9),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Parent = background,
	}


	local toolbar = Toolbar(props)
	toolbar.Parent = container

	return props, meta
end)

story:addTask("Add Tool", function(props)
	-- Get tool info
	local tools = props.Tools:get(false)

	-- Get remaining tool names
	local usedToolNames = {}
	local remainingToolsNames = {}

	for _, toolData in ipairs(tools) do
		usedToolNames[toolData.ToolName:get(false)] = true
	end

	for _, toolName in ipairs(randomToolNames) do
		if not usedToolNames[toolName] then
			table.insert(remainingToolsNames, toolName)
		end
	end

	-- Guard
	if #remainingToolsNames == 0 then return end

	-- Create tool data
	local toolData = {
		ToolName = Value(remainingToolsNames[math.random(1, #remainingToolsNames)]),
		Selected = Value(false),
	}

	-- Add tool to list
	local newTools = table.clone(tools)
	table.insert(newTools, toolData)
	props.Tools:set(newTools)
end)

story:addTask("Remove tool", function(props)
	-- Get tool info
	local tools = props.Tools:get(false)

	-- Get random tool
	local toolIndex = math.random(1, #tools)

	-- Remove tool from list
	local newTools = table.clone(tools)
	table.remove(newTools, toolIndex)
	props.Tools:set(newTools)
end)

story:addTask("Remove selected", function(props)
	-- Get tool info
	local tools = props.Tools:get(false)

	-- Get selected tool
	for index, toolData in ipairs(tools) do
		if toolData.Selected:get(false) then
			local newTools = table.clone(tools)
			table.remove(newTools, index)
			props.Tools:set(newTools)
			break
		end
	end
end)

story:addTask("Toggle bottom", function(_props, meta)
	meta.Bottom:set(not meta.Bottom:get(false))
end)

return story:toStory()
