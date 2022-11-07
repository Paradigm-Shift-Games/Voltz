local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local StoryTaskBar = require(Packages.StoryTaskBar)
local Fusion = require(Packages.Fusion)

local StatsContainer = require(script.Parent)

local New = Fusion.New
local Value = Fusion.Value
local Spring = Fusion.Spring
local Computed = Fusion.Computed

local story = StoryTaskBar()

story:setBackgroundSize(UDim2.fromScale(1, 1))

story:setConstructor(function(background)
	local props = {
		Iridium = Value(math.random(0, 100)),
		Health = Value(math.random(0, 100)),
		Fuel = Value(math.random(0, 100)),
		MaxIridium = Value(100),
		MaxHealth = Value(100),
		MaxFuel = Value(100),
	}

	local inCorner = Value(false)

	local frame = New "Frame" {
		BackgroundTransparency = 1,
		Size = Spring(Computed(function()
			if inCorner:get() then
				return UDim2.fromScale(1, 0.13)
			else
				return UDim2.fromScale(0.33, 0.33)
			end
		end), 18, 0.9),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = Spring(Computed(function()
			if inCorner:get() then
				return UDim2.fromScale(0.5, 0.065)
			else
				return UDim2.fromScale(0.5, 0.5)
			end
		end), 18, 1)
	}

	local container = StatsContainer(props)
	container.Parent = frame
	frame.Parent = background

	return props, inCorner
end)

story:addTask("Random Iridium", function(props)
	props.Iridium:set(math.random(0, 100))
end)

story:addTask("Random HP", function(props)
	props.Health:set(math.random(0, 100))
end)

story:addTask("Random Fuel", function(props)
	props.Fuel:set(math.random(0, 100))
end)

story:addTask("Toggle Corner", function(_props, inCorner)
	inCorner:set(not inCorner:get(false))
end)

return story:toStory()
