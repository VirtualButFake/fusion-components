local fusion = require("@packages/fusion")

local Computed = fusion.Computed
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use

local baseButton = require("@components/base/button")
local baseText = require("@components/base/text")

local theme = require("@src/theme")

type props = {
	Color: fusion.CanBeState<string>,
	Variant: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Label: fusion.CanBeState<string>,
	Index: fusion.CanBeState<number>,
	SelectedIndex: fusion.Value<number>,
	SizePer: fusion.CanBeState<number>,
	Disabled: fusion.CanBeState<boolean>,
	OnSelect: ((index: number) -> nil)?,
}

local function tabElement(props: props): TextButton
	local isHovering = Value(false)
	local isPressing = Value(false)

	local useColor = theme:get(
		"tabs",
		props.Color,
		props.Variant,
		Computed(function()
			if use(props.Index) == use(props.SelectedIndex) then
				if use(props.Disabled) then
					return "ActiveDisabled"
				end

				return "Active"
			elseif use(props.Disabled) then
				return "Disabled"
			elseif isPressing:get() then
				return "Press"
			elseif isHovering:get() then
				return "Hover"
			end

			return "Base"
		end),
		props.AppearanceOverride
	)

	local isVisible = Computed(function()
		if isHovering:get() or use(props.Index) == use(props.SelectedIndex) then
			return true
		else
			return false
		end
	end)

	local component = baseButton({
		Name = "TabButton",
		Appearance = Computed(function()
			local color = useColor("Background")
			color.transparency = isVisible:get() and color.transparency or 1
			return color
		end),
		Stroke = Computed(function()
			local color = useColor("Stroke")
			color.transparency = isVisible:get() and color.transparency or 1
			return color
		end),
		TweenSettings = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		AutoButtonColor = false,
		Content = {
			baseText({
				Name = "TabButtonText",
				Appearance = useColor("Text", true),
				Text = props.Label,
				FontFace = use(theme.global.font),
				Size = UDim2.fromScale(1, 1),
				TextSize = 18,
				TextTransparency = 0,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),
		},
		DisableHoverLighting = Computed(function()
			return use(props.Disabled) or use(props.Index) == use(props.SelectedIndex)
		end),
		OnClick = function()
			if not use(props.Disabled) then
				if props.OnSelect then
					props.OnSelect(use(props.Index))
				else
					props.SelectedIndex:set(use(props.Index))
				end
			end
		end,
		OnHover = function(state)
			isHovering:set(state)
		end,
		OnMouseButton1Changed = function(state)
			isPressing:set(state)
		end,
		Size = Computed(function()
			return UDim2.new(use(props.SizePer), -4, 1, 0)
		end),
	})

	return component
end

return tabElement
