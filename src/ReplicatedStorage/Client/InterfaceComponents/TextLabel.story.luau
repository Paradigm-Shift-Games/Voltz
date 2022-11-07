local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local StoryTaskBar = require(Packages.StoryTaskBar)
local TextLabel = require(script.Parent.TextLabel)
local Fusion = require(Packages.Fusion)

local Value = Fusion.Value

local story = StoryTaskBar()

story:setBackgroundSize(UDim2.new(0, 100, 0, 50))

story:setConstructor(function(background)
	local props = {
		Name = "TestLabel",
		Size = UDim2.new(1, 0, 1, 0),
		Text = "Test",
		ShadowTransparency = 0.5,
		StrokeSize = 2.75,
		ShadowOffset = UDim2.new(0, 0, 0.1, 0),
	}

	local label = TextLabel(props)
	label.Parent = background

	return props
end)

return story:toStory()
