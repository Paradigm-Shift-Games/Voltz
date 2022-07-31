local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Fusion = require(Packages.Fusion)
local WrappedFusion = require(Packages.FusionUtils).Wrapped
local Oklab = require(Packages.Oklab)

local UIComponents = script.Parent
local StatBar = require(UIComponents.StatsContainer.StatBar)

local New = WrappedFusion.New
local OnEvent = WrappedFusion.OnEvent
local Statify = WrappedFusion.Statify
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local RED_VECTOR = Oklab.to(Color3.new(1, 0, 0.125))
local YELLOW_VECTOR = Oklab.to(Color3.new(1, 1, 0.125))
local GREEN_VECTOR = Oklab.to(Color3.new(0, 1, 0.125))
local IRIDIUM_COLOR = Color3.new(0.109803, 0.925490, 1)
local FUEL_COLOR = Color3.new(1, 0.407843, 0.109803)
local IRIDIUM_VECTOR = Oklab.to(IRIDIUM_COLOR)

local function StatsContainer(props)
	local iridium = Statify(props.Iridium or 100)
	local health = Statify(props.Health or 100)
	local fuel = Statify(props.Fuel or 100)
	local maxIridium = Statify(props.MaxIridium or 100)
	local maxHealth = Statify(props.MaxHealth or 100)
	local maxFuel = Statify(props.MaxFuel or 100)

	local iridiumPercentage = Spring(Computed(function()
		return iridium:get() / maxIridium:get() * 100
	end), 18, 0.9)

	local iridiumText = Computed(function()
		local percent = iridiumPercentage:get()
		local max = maxIridium:get()
		return math.round(percent * max / 100) .. "/" .. max
	end)

	local iridiumColor = Computed(function()
		local percent = iridiumPercentage:get()

		if percent >= 30 then
			return Oklab.from(YELLOW_VECTOR:Lerp(IRIDIUM_VECTOR, (percent - 30) / 70))
		else
			return Oklab.from(RED_VECTOR:Lerp(YELLOW_VECTOR, percent / 30))
		end
	end)

	local healthPercentage = Spring(Computed(function()
		return health:get() / maxHealth:get() * 100
	end), 18, 0.9)

	local healthText = Computed(function()
		local percent = healthPercentage:get()
		local max = maxHealth:get()
		return math.round(percent * max / 100) .. "/" .. max
	end)

	local healthColor = Computed(function()
		local percent = healthPercentage:get()

		if percent >= 50 then
			return Oklab.from(YELLOW_VECTOR:Lerp(GREEN_VECTOR, (percent - 50) / 50))
		else
			return Oklab.from(RED_VECTOR:Lerp(YELLOW_VECTOR, percent / 50))
		end
	end)

	local fuelPercentage = Spring(Computed(function()
		return fuel:get() / maxFuel:get() * 100
	end), 18, 0.9)

	return New "Frame" {
		Size = UDim2.fromScale(1, 1), -- 0.13
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -15, 0, 15),
		BackgroundTransparency = 1,

		[Children] = {
			New "UIAspectRatioConstraint" {
				AspectRatio = 1.9,
			},

			New "ImageLabel" {
				Name = "IridiumContainer",
				Size = UDim2.fromScale(0.93, 0.6),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://10431149686",
				ImageColor3 = Color3.new(),
				ImageTransparency = 0.375,
				ScaleType = Enum.ScaleType.Fit,

				[Children] = {
					New "Frame" {
						Name = "IridiumTitle",
						Size = UDim2.fromScale(0.6, 0.4),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0.066),
						BackgroundTransparency = 1,

						[Children] = {
							New "ImageLabel" {
								Name = "IridiumIcon",
								Size = UDim2.fromScale(0.2, 0.7),
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.fromScale(0, 0.5),
								BackgroundTransparency = 1,
								Image = "rbxassetid://10431851659",
								ScaleType = Enum.ScaleType.Fit,
								ImageColor3 = iridiumColor,
							},

							New "TextLabel" {
								Name = "IridiumTitle",
								Size = UDim2.fromScale(0.8, 1),
								AnchorPoint = Vector2.new(0, 0.5),
								Position = UDim2.fromScale(0.2, 0.5),
								BackgroundTransparency = 1,
								Font = Enum.Font.GothamMedium,
								TextColor3 = iridiumColor,
								Text = "Iridium",
								TextScaled = true,
								TextXAlignment = Enum.TextXAlignment.Right,
							}
						}
					},

					New "TextLabel" {
						Name = "IridiumLabel",
						Size = UDim2.fromScale(0.7, 0.4),
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0.533),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamMedium,
						TextColor3 = iridiumColor,--Color3.new(1, 1, 1),
						Text = iridiumText,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Center,
					}
				}
			},

			--[[New "ImageLabel" {
				Name = "IridiumBar",
				Size = UDim2.fromScale(0.11, 0.6),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(0.13, 0),
				BackgroundTransparency = 1,
				Image = "rbxassetid://10431214160",
				ImageColor3 = Color3.new(),
				ImageTransparency = 0.375,
				ScaleType = Enum.ScaleType.Fit,
			},]]

			New "Frame" {
				Name = "IridiumBar",
				Size = UDim2.fromScale(0.11, 0.6),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(0.13, 0),
				BackgroundTransparency = 1,

				[Children] = {
					StatBar {
						FillPercentage = iridiumPercentage,
						Color = IRIDIUM_COLOR,
					}
				}
			},

			New "Frame" {
				Name = "FuelBar",
				Size = UDim2.fromScale(0.11, 0.6),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(0.072, 0),
				BackgroundTransparency = 1,

				[Children] = {
					StatBar {
						FillPercentage = fuelPercentage,
						Color = FUEL_COLOR,
					}
				}
			},

			New "ImageLabel" {
				Name = "HealthContainer",
				Size = UDim2.fromScale(0.935, 0.35),
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://10431385017",
				ImageColor3 = Color3.new(),
				ImageTransparency = 0.375,
				ScaleType = Enum.ScaleType.Fit,

				[Children] = {
					New "ImageLabel" {
						Name = "HealthIcon",
						Size = UDim2.fromScale(0.2, 0.5),
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0, 0.5),
						BackgroundTransparency = 1,
						Image = "rbxassetid://10431575202",
						ImageColor3 = healthColor,
						ScaleType = Enum.ScaleType.Fit,
					},

					New "TextLabel" {
						Name = "HealthText",
						Size = UDim2.fromScale(0.7, 0.5),
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.fromScale(0.2, 0.5),
						BackgroundTransparency = 1,
						Font = Enum.Font.GothamMedium,
						TextColor3 = healthColor,
						Text = healthText,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left,
					}
				}
			},
		}
	}
end

return StatsContainer