local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local StoryTaskBar = require(Packages.StoryTaskBar)
local Fusion = require(Packages.Fusion)

local StatBar = require(script.Parent.StatBar)

local Value = Fusion.Value
local Spring = Fusion.Spring
local Computed = Fusion.Computed

local story = StoryTaskBar()

story:setBackgroundSize(UDim2.new(0.5, 0, 0.3, 0))

story:setConstructor(function(background)
	-- Default props that indicate what you might use
	local props = {
		FillPercentage = Value(100),
		Color = Value(Color3.new(1, 1, 1)),
	}

	-- Overwrite default props
	local fillPercentage = props.FillPercentage
	props.FillPercentage = Spring(fillPercentage, 30, 0.9)
	props.Color = Computed(function()
		local percent = props.FillPercentage:get()
		return Color3.fromRGB(255 - 225*percent/100, 30 + 225*percent/100, 30)
	end)

	local statBar = StatBar(props)
	statBar.Parent = background

	return props, fillPercentage
end)

story:addTask("Set Random", function(_props, fillPercentage)
	fillPercentage:set(math.random(0, 100))
end)

return story:toStory()
