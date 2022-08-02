local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Fusion = require(Packages.Fusion)
local WrappedFusion = require(Packages.FusionUtils).Wrapped

local UIComponents = script.Parent.Parent
local ClientSrc = UIComponents.Parent

local SharedInterfaceState = require(ClientSrc.SharedInterfaceState)
local Button = require(UIComponents.Button)

local New = WrappedFusion.New
local Statify = WrappedFusion.Statify
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Out = Fusion.Out

local function ToolbarItem(props)
	-- Basic states
	local hovering = props.Hovering or Value(false)
	local pressing = props.Pressing or Value(false)
	local visible = Statify(if props.Visible ~= nil then props.Visible else true)
	local selected = Statify(props.Selected or false)

	-- Tool data states
	local inputName = Statify(props.InputName)
	local toolName = Statify(props.ToolName)

	-- Sizing states
	local inputNameTextBounds = Value(Vector2.new())
	local toolNameTextBounds = Value(Vector2.new())
	local absoluteButtonSize = Value(Vector2.new())


	-- Size States
	local paddingSize = Computed(function()
		local currentAbsoluteButtonSize = absoluteButtonSize:get()

		if currentAbsoluteButtonSize == nil then
			return 0
		else
			return currentAbsoluteButtonSize.Y / 10
		end
	end)

	local buttonSize = Spring(Computed(function()
		local isVisible = visible:get()
		local currentAbsoluteButtonSize = absoluteButtonSize:get()
		local currentInputNameTextBounds = inputNameTextBounds:get()
		local currentToolNameTextBounds = toolNameTextBounds:get()

		if currentAbsoluteButtonSize == nil or currentInputNameTextBounds == nil or currentToolNameTextBounds == nil or isVisible == false then
			return UDim2.fromScale(0, 1)
		else
			local width = paddingSize:get() * 4 + currentInputNameTextBounds.X + currentToolNameTextBounds.X
			return UDim2.new(0, width, 1, 0)
		end
	end), 20, 0.9)

	local buttonContainerSize = Spring(Computed(function()
		local isVisible = visible:get()
		local currentAbsoluteButtonSize = absoluteButtonSize:get()

		if not isVisible or currentAbsoluteButtonSize == nil then
			return UDim2.fromScale(0, 1)
		else
			return UDim2.new(0, absoluteButtonSize:get().X, 1, 0) + UDim2.fromOffset(paddingSize:get() * 2, 0)
		end
	end), 20, 0.9)

	local textContainerSize = Computed(function()
		local currentInputNameTextBounds = inputNameTextBounds:get()
		local currentToolNameTextBounds = toolNameTextBounds:get()

		if currentInputNameTextBounds == nil or currentToolNameTextBounds == nil then
			return UDim2.fromScale(0, 1)
		else
			local width = currentInputNameTextBounds.X + currentToolNameTextBounds.X + paddingSize:get() * 3
			return UDim2.new(0, width, 1, 0)
		end
	end)


	-- Position States
	local inputNameTextPosition = Computed(function()
		return UDim2.new(0, paddingSize:get(), 0.5, 0)
	end)

	local toolNameTextPosition = Computed(function()
		local currentInputNameTextBounds = inputNameTextBounds:get()

		if currentInputNameTextBounds == nil then
			return UDim2.new()
		else
			return UDim2.new(0, currentInputNameTextBounds.X + paddingSize:get() * 2, 0.5, 0)
		end
	end)


	-- Transparency/Thickness States
	local backgroundTransparency = Spring(Computed(function()
		if selected:get() and hovering:get() then
			return 0.2
		elseif selected:get() then
			return 0.3
		elseif hovering:get() then
			return 0.4
		else
			return 0.525
		end
	end), 20, 0.9)

	local strokeTransparency = Spring(Computed(function()
		return if selected:get() then 0 else 1
	end), 20, 0.9)

	local strokeThickness = Spring(Computed(function()
		return if selected:get() then SharedInterfaceState.StrokeSize:get() else 0
	end), 20, 0.9)

	local textTransparency = Spring(Computed(function()
		return if visible:get() then 0 else 1
	end), 20, 0.9)


	-- Create Button
	return New "Frame" {
		Name = "ButtonContainer",
		Size = buttonContainerSize,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),

		[Children] = {
			Button {
				Name = "Button",
				Size = buttonSize,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = Color3.new(),
				BackgroundTransparency = backgroundTransparency,
				Hovering = hovering,
				Pressing = pressing,
				LayoutOrder = props.LayoutOrder,
				OnPressUp = props.OnPressUp,
				OnPressDown = props.OnPressDown,

				[Out "AbsoluteSize"] = absoluteButtonSize,

				[Children] = {
					New "UICorner" {
						CornerRadius = UDim.new(0.05, 0),
					},

					New "Frame" {
						Name = "StrokeContainer",
						Size = UDim2.fromScale(1, 1),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						BackgroundTransparency = 1,

						[Children] = {
							New "UICorner" {
								CornerRadius = UDim.new(0.05, 0),
							},
							New "UIStroke" {
								Color = Color3.new(1, 1, 1),
								Thickness = strokeThickness,
								Transparency = strokeTransparency,
							},
						}
					},

					New "Frame" {
						Name = "TextContainerClipDescendants",
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						ClipsDescendants = true,

						[Children] = {
							New "Frame" {
								Name = "TextContainer",
								Size = textContainerSize,
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								BackgroundTransparency = 1,
								ClipsDescendants = true,

								[Children] = {
									New "TextLabel" {
										Name = "InputName",
										Size = UDim2.new(1, 500, 0.33, 0),
										AnchorPoint = Vector2.new(0, 0.5),
										Position = inputNameTextPosition,
										BackgroundTransparency = 1,
										Text = inputName,
										TextColor3 = Color3.new(0.639215, 0.639215, 0.639215),
										TextXAlignment = Enum.TextXAlignment.Left,
										TextScaled = true,
										TextTransparency = textTransparency,
										Font = Enum.Font.GothamBlack,

										[Out "TextBounds"] = inputNameTextBounds,
									},

									New "TextLabel" {
										Name = "ToolName",
										Size = UDim2.new(1, 500, 0.33, 0),
										AnchorPoint = Vector2.new(0, 0.5),
										Position = toolNameTextPosition,
										BackgroundTransparency = 1,
										Text = toolName,
										TextColor3 = Color3.new(1, 1, 1),
										TextXAlignment = Enum.TextXAlignment.Left,
										TextScaled = true,
										TextTransparency = textTransparency,
										Font = Enum.Font.GothamBlack,

										[Out "TextBounds"] = toolNameTextBounds,
									},
								}
							},
						}
					}
				}
			}
		}
	}
end

return ToolbarItem