local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Fusion = require(Packages.Fusion)
local WrappedFusion = require(Packages.FusionUtils).Wrapped

local New = Fusion.New
local Statify = WrappedFusion.Statify
local Children = Fusion.Children
local Computed = Fusion.Computed

-- Project-wide defaults
local DEFAULT_FONT = Enum.Font.GothamBlack
local DEFAULT_TEXT = ""
local DEFAULT_TEXT_COLOR = Color3.new(1, 1, 1)
local DEFAULT_TEXT_POSITION = UDim2.new(0, 0, 0.15, 0)
local DEFAULT_TEXT_TRANSPARENCY = 0
local DEFAULT_SHADOW_TRANSPARENCY = 1
local DEFAULT_SHADOW_OFFSET = UDim2.new(0, 0, 0.125, 0)
local DEFAULT_SHADOW_COLOR = Color3.new()
local DEFAULT_STROKE_SIZE = 0
local DEFAULT_STROKE_TRANSPARENCY = 0
local DEFAULT_STROKE_COLOR = Color3.new()

local function TextLabel(props)
	local shadowTransparency = Statify(props.ShadowTransparency or DEFAULT_SHADOW_TRANSPARENCY)
	local shadowOffset = Statify(props.ShadowOffset or DEFAULT_SHADOW_OFFSET)
	local shadowColor = props.ShadowColor or DEFAULT_SHADOW_COLOR
	local strokeSize = Statify(props.StrokeSize or DEFAULT_STROKE_SIZE)
	local strokeColor = props.StrokeColor or DEFAULT_STROKE_COLOR
	local strokeTransparency = Statify(props.StrokeTransparency or DEFAULT_STROKE_TRANSPARENCY)
	local font = props.Font or DEFAULT_FONT
	local text = props.Text or DEFAULT_TEXT
	local textColor = props.TextColor3 or DEFAULT_TEXT_COLOR
	local textTransparency = props.TextTransparency or DEFAULT_TEXT_TRANSPARENCY

	return New "Frame" {
		Name = props.Name or text or "GenericTextLabel",
		BackgroundTransparency = props.BackgroundTransparency or 1,
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		Size = props.Size or UDim2.new(1, 0, 1, 0),
		Position = props.Position or DEFAULT_TEXT_POSITION,
		Rotation = props.Rotation,
		ZIndex = props.ZIndex,

		[Children] = {
			New "TextLabel" {
				Name = "Text",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				TextColor3 = textColor,
				TextTransparency = textTransparency,
				TextStrokeTransparency = 1,
				TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
				TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
				Text = text,
				TextScaled = true,

				Font = font,
				ZIndex = 2,

				[Children] = {
					New "UIStroke" {
						Color = strokeColor,
						Thickness = strokeSize,
						Transparency = Computed(function()
							return if strokeSize:get() > 0 then strokeTransparency:get() else 1
						end),
					},
				},
			},

			New "TextLabel" {
				Name = "TextShadow",
				Size = UDim2.new(1, 0, 1, 0),
				Position = shadowOffset,
				BackgroundTransparency = 1,
				TextColor3 = shadowColor,
				TextStrokeTransparency = 1,
				TextTransparency = shadowTransparency,
				TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
				TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
				Text = text,
				TextScaled = true,
				Font = font,
				ZIndex = 1,
			},
		},
	}
end

return TextLabel
