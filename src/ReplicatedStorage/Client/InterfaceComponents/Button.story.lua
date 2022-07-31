local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local StoryTaskBar = require(Packages.StoryTaskBar)
local Fusion = require(Packages.Fusion)

local Button = require(script.Parent.Button)
local TextLabel = require(script.Parent.TextLabel)

local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Tween = Fusion.Tween
local New = Fusion.New

local story = StoryTaskBar()

story:setBackgroundSize(UDim2.new(0.4, 0, 0.25, 0))

story:setConstructor(function(background)
	local hovering = Value(false)
	local pressing = Value(false)

	local transparency = Tween(
		Computed(function()
			if pressing:get() then
				return 0.35
			elseif hovering:get() then
				return 0.5
			else
				return 0.65
			end
		end),
		TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	)

	local backgroundColor = Computed(function()
		local value = transparency:get() * 0.7
		return Color3.new(value, value, value)
	end)

	local cornerRadius = Tween(
		Computed(function()
			if pressing:get() then
				return UDim.new(0.51, 0)
			elseif hovering:get() then
				return UDim.new(0.1, 0)
			else
				return UDim.new(0.05, 0)
			end
		end),
		TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	)

	local props = {
		Name = "TestLabel",
		BackgroundTransparency = transparency,
		BackgroundColor3 = backgroundColor,
		Size = UDim2.new(1, 0, 1, 0),
		Rotation = 0,

		Hovering = hovering,
		Pressing = pressing,

		[Children] = {
			TextLabel {
				Name = "TestLabel",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.new(1, 0, 0.8, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Text = "Test",
				ShadowTransparency = 0.5,
				StrokeSize = 2.75,
				ShadowOffset = UDim2.new(0, 0, 0, 10),
			},

			New "UICorner" {
				CornerRadius = cornerRadius,
			},
		},
	}

	local button = Button(props)
	button.Parent = background

	return props
end)

return story:toStory()
