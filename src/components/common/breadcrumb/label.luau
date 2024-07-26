local fusion = require("@packages/fusion")

local Hydrate = fusion.Hydrate
local New = fusion.New

local Computed = fusion.Computed
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use
local propertyProvider = fusionUtils.propertyProvider

local theme = require("@src/theme")

local baseIcon = require("@components/base/icon")
local baseText = require("@components/base/text")
local baseButton = require("@components/base/button")

export type label = {
	Text: fusion.CanBeState<string> | baseText.text,
	Icon: fusion.CanBeState<string>?,
	Content: fusion.CanBeState<Instance>?,
	OnClick: () -> ()?,
}

type props = {
	Color: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Label: label,
	Selected: fusion.Computed<boolean>,
	[a]: any,
}

local function breadcrumbLabel(props: props): TextButton
	local isHovering = Value(false)

	local useColor = theme:get(
		"breadcrumb",
		props.Color,
		"default",
		Computed(function()
			if props.Selected:get() then
				return "Selected"
			end

			if use(props.Label).OnClick then
				if isHovering:get() then
					return "Hover"
				else
					return "Base"
				end
			end

			return "Base"
		end),
		props.AppearanceOverride
	)

	local text = use(props.Label.Text)
	local textSize = typeof(text) == "table" and use(use(text).Size) or 16

	local component = baseButton({
		TweenSettings = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Content = {
			New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			props.Label.Icon and baseIcon({
				Name = "BreadcrumbLabelIcon",
				Icon = {
					Name = use(props.Label.Icon),
					Size = textSize,
				},
				Color = useColor("Text", true),
			}),
			baseText({
				Name = "BreadcrumbLabelText",
				Appearance = useColor("Text", true),
				Text = props.Label.Text,
				AutomaticSize = Enum.AutomaticSize.XY,
				FontFace = Font.new(use(theme.global.font).Family, Enum.FontWeight.SemiBold),
				TextSize = textSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
			}),
		},
		OnClick = function()
			local label = use(props.Label)

			if label.OnClick then
				label.OnClick()
			end
		end,
		OnHover = function(hovering)
			isHovering:set(hovering)
		end,
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "TextButton")) :: TextButton
end

return breadcrumbLabel
