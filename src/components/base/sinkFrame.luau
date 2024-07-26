-- A 1:1 of the frame.lua base component, as a TextButton, so input sinks. https://devforum.roblox.com/t/gui-button-mouse-events-dont-respect-z-order/25866
local fusion = require("@packages/fusion")
local Tween = fusion.Tween

local Children = fusion.Children
local Hydrate = fusion.Hydrate
local New = fusion.New
local Out = fusion.Out

local Clean = fusion.cleanup
local Computed = fusion.Computed
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use
local peek = fusionUtils.peek
local propertyProvider = fusionUtils.propertyProvider

local theme = require("@src/theme")

local shadow = require("@components/utility/shadow")

type props = {
	Appearance: fusion.CanBeState<theme.color>?,
	Stroke: fusion.CanBeState<theme.color>?,
	TweenSettings: TweenInfo?,
	CornerRadius: number? | UDim?,
	Padding: fusion.CanBeState<UDim>? | {
		Top: fusion.CanBeState<UDim>?,
		Bottom: fusion.CanBeState<UDim>?,
		Left: fusion.CanBeState<UDim>?,
		Right: fusion.CanBeState<UDim>?,
	}?,
	Content: fusion.CanBeState<{ Instance }>?,
	[any]: any,
}

local function sinkFrame(props: props)
	if props.TweenSettings == nil then
		props.TweenSettings = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	end

	if props.CornerRadius == nil then
		props.CornerRadius = 4
	end

	local backgroundColor = props.BackgroundColor3
		or peek(props.Appearance) ~= nil and Tween(
			Computed(function()
				return use(props.Appearance).color
			end),
			props.TweenSettings
		)
		or Color3.fromRGB(255, 255, 255)

	local backgroundTransparency = props.BackgroundTransparency
		or peek(props.Appearance) ~= nil and Tween(
			Computed(function()
				return use(props.Appearance).transparency
			end),
			props.TweenSettings
		)
		or 0

	local elevation = peek(props.Appearance) and Computed(function()
		return use(props.Appearance).shadow
	end) or nil

	local targetSize = Value()
	local appearanceChildren = {
		Computed(function()
			if props.CornerRadius and use(props.CornerRadius) ~= 0 then
				return New("UICorner")({
					CornerRadius = typeof(props.CornerRadius) == "UDim" and props.CornerRadius
						or UDim.new(0, props.CornerRadius :: number),
				})
			end

			return nil
		end, Clean),
		props.Stroke and New("UIStroke")({
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Tween(
				Computed(function()
					return use(props.Stroke).color
				end),
				props.TweenSettings
			),
			Transparency = Tween(
				Computed(function()
					return use(props.Stroke).transparency
				end),
				props.TweenSettings
			),
		}),
		Computed(function()
			if props.Padding and use(props.Padding) ~= 0 then
				local padding = props.Padding

				if typeof(padding) == "table" then
					if padding.Top == 0 and padding.Bottom == 0 and padding.Left == 0 and padding.Right == 0 then
						return nil
					end

					return New("UIPadding")({
						PaddingBottom = padding.Bottom or UDim.new(0, 0),
						PaddingLeft = padding.Left or UDim.new(0, 0),
						PaddingRight = padding.Right or UDim.new(0, 0),
						PaddingTop = padding.Top or UDim.new(0, 0),
					})
				else
					if padding == UDim.new(0, 0) then
						return nil
					end

					return New("UIPadding")({
						PaddingBottom = padding or UDim.new(0, 0),
						PaddingLeft = padding or UDim.new(0, 0),
						PaddingRight = padding or UDim.new(0, 0),
						PaddingTop = padding or UDim.new(0, 0),
					})
				end
			end

			return nil
		end, Clean),
	}

	local renderContent = elevation or props.Content

	local component = New("TextButton")({
		Name = renderContent and "Container" or "Content",
		BackgroundColor3 = renderContent and Color3.fromRGB(255, 255, 255) or backgroundColor,
		BackgroundTransparency = renderContent and 1 or backgroundTransparency,
		Text = "",
		[Out("AbsoluteSize")] = targetSize,
		[Children] = {
			elevation and shadow({
				Elevation = elevation,
				TargetSize = targetSize,
			}),
			not renderContent and appearanceChildren or nil,
			renderContent and New("Frame")({
				Name = "ContentFrame",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = backgroundColor,
				BackgroundTransparency = backgroundTransparency,
				Size = UDim2.new(1, 0, 1, 0),
				[Children] = {
					appearanceChildren,
					props.Content,
				},
			}),
		},
	})

	local properties = propertyProvider.getPropsAndSpecialKeys(props, "TextButton")
	return Hydrate(component)(properties)
end

return sinkFrame
