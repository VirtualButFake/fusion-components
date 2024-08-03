local fusion = require("@packages/fusion")

local Children = fusion.Children
local Hydrate = fusion.Hydrate
local New = fusion.New

local Computed = fusion.Computed

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use
local propertyProvider = fusionUtils.propertyProvider
local getState = fusionUtils.getState

local theme = require("@src/theme")

local baseIcon = require("@components/base/icon")
local baseButton = require("@components/base/button")
local baseText = require("@components/base/text")

type props = {
	Color: fusion.CanBeState<string>,
	Variant: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Hovering: fusion.CanBeState<boolean>?,
	Pressing: fusion.CanBeState<boolean>?,
	Disabled: fusion.CanBeState<boolean>?,
	DisableHoverLighting: boolean?,
	Padding: number?,
	ContentSpacing: number?,
	ButtonText: fusion.CanBeState<string>? | baseText.text,
	Icon: string? | baseIcon.icon?,
	TrailingIcon: string? | baseIcon.icon?,
	Content: fusion.CanBeState<{ Instance }>?,
	ContentFullSize: boolean?,
	OnMouseChanged: ((isDown: boolean) -> nil)?,
	OnClick: (() -> nil)?,
	OnHover: ((isHovering: boolean) -> nil)?,
	OnMouseButton2Changed: ((isDown: boolean) -> nil)?,
	OnMouseButton2Clicked: (() -> nil)?,
	DisablePressHandler: boolean?,
	DisableHoverHandler: boolean?,
	[any]: any,
}

local function button(props: props): TextButton
	local isHovering = getState(props.Hovering or false)
	local isPressing = getState(props.Pressing or false)

	local useColor = theme:get(
		"button",
		props.Color,
		props.Variant,
		Computed(function()
			if use(props.Disabled) then
				return "Disabled"
			elseif use(isPressing) then
				return "Pressing"
			elseif use(isHovering) then
				return "Hover"
			else
				return "Base"
			end
		end),
		props.AppearanceOverride
	)

	local automaticSizeProp = props.AutomaticSize or Enum.AutomaticSize.XY

	local component = baseButton({
		Name = "ButtonMain",
		Appearance = useColor("Background", true),
		Stroke = useColor("Stroke", true),
		Padding = UDim.new(0, props.Padding or 4),
		AutomaticSize = automaticSizeProp,
		Content = {
			Content = {
				props.ButtonText and baseText({
					Name = "Text",
					Appearance = useColor("Text", true),
					Text = props.ButtonText,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					LayoutOrder = 1,
				}),
				props.Icon and baseIcon({
					Name = "Icon",
					Icon = typeof(props.Icon) == "table" and props.Icon or {
						Name = props.Icon,
						Size = 16,
					},
					Color = useColor("Text", true),
					LayoutOrder = 0,
				}),
				props.TrailingIcon and baseIcon({
					Name = "TrailingIcon",
					Icon = typeof(props.TrailingIcon) == "table" and props.TrailingIcon or {
						Name = props.TrailingIcon,
						Size = 16,
					},
					Color = useColor("Text", true),
					LayoutOrder = 2,
				}),
				props.Content and New("Frame")({
					Name = "Content",
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Size = props.ContentFullSize and UDim2.new(1, 0, 1, 0) or UDim2.new(),
					[Children] = props.Content,
				}),
				New("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, props.ContentSpacing or 4),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
			},
		},
		DisableHoverLighting = props.DisableHoverLighting or props.Disabled,
		OnClick = function()
			if use(props.Disabled) then
				return
			end

			if props.OnClick then
				props.OnClick()
			end
		end,
		OnHover = function(state)
			if isHovering.set and not props.DisableHoverHandler then
				isHovering:set(state)
			end

			if props.OnHover then
				props.OnHover(state)
			end
		end,
		OnMouseButton1Changed = function(isPressed)
			if isPressed then
				if use(props.Disabled) then
					return
				end

				if isPressing.set and not props.DisablePressHandler then
					isPressing:set(true)
				end
			else
				if isPressing.set and not props.DisablePressHandler then
					isPressing:set(isPressed)
				end
			end

			if props.OnMouseChanged then
				props.OnMouseChanged(isPressed)
			end
		end,
		OnMouseButton2Changed = function(isPressed)
			if props.OnMouseButton2Changed then
				props.OnMouseButton2Changed(isPressed)
			end
		end,
		OnMouseButton2Clicked = function()
			if props.OnMouseButton2Clicked then
				props.OnMouseButton2Clicked()
			end
		end,
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "TextButton")) :: TextButton
end

return button
