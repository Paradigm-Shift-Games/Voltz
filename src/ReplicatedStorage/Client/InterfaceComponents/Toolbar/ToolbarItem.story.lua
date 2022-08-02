local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local StoryTaskBar = require(Packages.StoryTaskBar)
local Fusion = require(Packages.Fusion)

local ToolbarItem = require(script.Parent.ToolbarItem)

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
}

story:setBackgroundSize(UDim2.new(0.3, 0, 0.3, 0))

story:setConstructor(function(background)
	local props = {
		Selected = Value(false),
		InputName = Value(tostring(math.random(0, 9))),
		ToolName = Value(randomToolNames[math.random(1, #randomToolNames)]),
		Visible = Value(true),
	}

	local toolbarItem = ToolbarItem(props)
	toolbarItem.Parent = background

	return props
end)

story:addTask("Toggle", function(props)
	props.Visible:set(not props.Visible:get(false))
end)

story:addTask("Toggle Select", function(props)
	props.Selected:set(not props.Selected:get(false))
end)

story:addTask("Randomize", function(props)
	props.InputName:set(tostring(math.random(0, 9)))
	props.ToolName:set(randomToolNames[math.random(1, #randomToolNames)])
end)

return story:toStory()
