local fusion = require("@packages/fusion")
local Tween = fusion.Tween

local Children = fusion.Children
local Hydrate = fusion.Hydrate
local New = fusion.New
local Event = fusion.OnEvent
local Out = fusion.Out
local Ref = fusion.Ref

local Clean = fusion.cleanup
local Computed = fusion.Computed
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use
local peek = fusionUtils.peek
local propertyProvider = fusionUtils.propertyProvider

local theme = require("@src/theme")

local shadow = require("@components/utility/shadow")
local hoverLighting = require("@components/utility/hoverLighting")

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
	OnClick: (() -> nil)?,
	OnMouseButton2Click: (() -> nil)?,
	OnMouseButton1Changed: ((isDown: boolean) -> nil)?,
	OnMouseButton2Changed: ((isDown: boolean) -> nil)?,
	OnHover: ((hoverState: boolean) -> nil)?,
	DisableHoverLighting: fusion.CanBeState<boolean>?,
	[any]: any,
}

local function button(props: props)
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

	local isHovering = Value(false) -- isolating this here; there is no reason for components to make their own hover state

	local function setHover(state)
		if props.OnHover then
			props.OnHover(state)
		end

		isHovering:set(state)
	end

	local function setLeftPressed(state)
		if props.OnMouseButton1Changed then
			props.OnMouseButton1Changed(state)
		end
	end

	local function setRightPressed(state)
		if props.OnMouseButton2Changed then
			props.OnMouseButton2Changed(state)
		end
	end

	local componentRef = Value()
	local mousePosition = Value(Vector2.new())
	local targetSize = Value()

	local component = New("TextButton")({
		BackgroundTransparency = 1,
		Text = "",
		[Event("MouseButton1Click")] = props.OnClick,
		[Event("MouseButton2Click")] = props.OnMouseButton2Click,
		[Out("AbsoluteSize")] = targetSize,
		[Event("MouseButton1Down")] = function()
			setLeftPressed(true)
		end,
		[Event("MouseButton1Up")] = function()
			setLeftPressed(false)
		end,
		[Event("MouseButton2Down")] = function()
			setRightPressed(true)
		end,
		[Event("MouseButton2Up")] = function()
			setRightPressed(false)
		end,
		[Event("MouseEnter")] = function()
			setHover(true)
		end,
		[Event("MouseLeave")] = function()
			setHover(false)
			setLeftPressed(false)
			setRightPressed(false)
		end,
		[Event("InputChanged")] = function(input: InputObject)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				mousePosition:set(Vector2.new(input.Position.X, input.Position.Y))
			end
		end,
		[Children] = {
			New("Frame")({
				Name = "Background",
				BackgroundColor3 = backgroundColor,
				BackgroundTransparency = backgroundTransparency,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = -2,
				[Ref] = componentRef,
				[Children] = {
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
				},
			}),
			props.Content and New("Frame")({
				Name = "ContentFrame",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 3,
				[Out("AbsoluteSize")] = targetSize,
				[Children] = {
					props.Content,
					Computed(function()
						if props.Padding and use(props.Padding) :: UDim ~= UDim.new(0, 0) then
							local padding = props.Padding

							if typeof(padding) == "table" then
								return New("UIPadding")({
									PaddingBottom = padding.Bottom or UDim.new(0, 0),
									PaddingLeft = padding.Left or UDim.new(0, 0),
									PaddingRight = padding.Right or UDim.new(0, 0),
									PaddingTop = padding.Top or UDim.new(0, 0),
								})
							else
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
				},
			}),
			Computed(function()
				local usedAppearance = use(props.Appearance)
				local elevation = usedAppearance and usedAppearance.shadow or nil

				if elevation == nil or elevation <= 0 then
					return nil
				end

				return shadow({
					Elevation = elevation,
					TargetSize = targetSize,
				})
			end, Clean),
			Computed(function()
				if use(props.DisableHoverLighting) then
					return nil
				end

				return hoverLighting({
					Component = componentRef,
					Hovering = isHovering,
					Position = mousePosition,
					CornerRadius = props.CornerRadius,
				})
			end),
		},
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "TextButton"))
end

return button
