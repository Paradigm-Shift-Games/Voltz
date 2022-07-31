local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Fusion = require(Packages.Fusion)
local WrappedFusion = require(Packages.FusionUtils).Wrapped
local Trove = require(Packages.Trove)

local New = WrappedFusion.New
local OnEvent = WrappedFusion.OnEvent
local Statify = WrappedFusion.Statify
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Cleanup = Fusion.Cleanup

local function StatBar(props)
	local color = Statify(props.Color or Color3.new(0.192156, 0.647058, 0.141176))
	local fillPercentage = Statify(props.FillPercentage or 50)

	local trove = Trove.new()
	local frameSize = Value(UDim2.new())

	local fillableBarSize = Computed(function()
		local percent = fillPercentage:get()
		return UDim2.new(1, 0, percent / 100, 0)
	end)

	local backgroundSize = Computed(function()
		local percent = fillPercentage:get()

		if percent == 100 then
			return UDim2.new(1, 0, 0, 0)
		else
			return UDim2.new(1, 0, 1 - (percent / 101), 0)
		end
	end)

	local frame = New "Frame" {
		Name = "StatBarContainer",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,

		[Cleanup] = {
			function()
				trove:Destroy()
			end
		},

		[Children] = {
			New "Frame" {
				Name = "FillContainer",
				Size = fillableBarSize,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				ZIndex = 2,

				[Children] = {
					New "ImageLabel" {
						Name = "Fill",
						Size = frameSize,
						AnchorPoint = Vector2.new(0, 1),
						Position = UDim2.fromScale(0, 1),
						BackgroundTransparency = 1,
						Image = "rbxassetid://10431214160",
						ImageTransparency = 0,
						ImageColor3 = color,
						ScaleType = Enum.ScaleType.Fit,
					},
				}
			},

			New "Frame" {
				Name = "BackgroundContainer",
				Size = backgroundSize,
				AnchorPoint = Vector2.new(0, 0),
				Position = UDim2.fromScale(0, 0),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				ZIndex = 1,

				[Children] = {
					New "ImageLabel" {
						Name = "BackgroundFill",
						Size = frameSize,
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.fromScale(0, 0),
						BackgroundTransparency = 1,
						Image = "rbxassetid://10431214160",
						ImageColor3 = Color3.new(),
						ImageTransparency = 0.375,
						ScaleType = Enum.ScaleType.Fit,
					},
				}
			}
		}
	}

	trove:Connect(frame:GetPropertyChangedSignal("AbsoluteSize"), function()
		local sizeVector = frame.AbsoluteSize
		frameSize:set(UDim2.fromOffset(sizeVector.X, sizeVector.Y))
	end)

	return frame
end

return StatBar