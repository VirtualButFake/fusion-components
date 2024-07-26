local fusion = require("@packages/fusion")

local Children = fusion.Children
local Hydrate = fusion.Hydrate
local New = fusion.New

local fusionUtils = require("@packages/fusionUtils")
local propertyProvider = fusionUtils.propertyProvider

local theme = require("@src/theme")

local baseIcon = require("@components/base/icon")
local baseFrame = require("@components/base/frame")
local baseText = require("@components/base/text")

type props = {
	Color: fusion.CanBeState<string>,
	Variant: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Padding: number?,
	ContentSpacing: number?,
	Text: string? | baseText.text?,
	Icon: baseIcon.icon?,
	TrailingIcon: baseIcon.icon?,
	Content: fusion.CanBeState<{ Instance }>?,
	[any]: any,
}

local function badge(props: props): Frame
	local useColor = theme:get("badge", props.Color, props.Variant, "Base", props.AppearanceOverride)

	local component = baseFrame({
		Name = "Badge",
		Appearance = useColor("Background", true),
		Stroke = useColor("Stroke", true),
		Padding = UDim.new(0, props.Padding or 4),
		AutomaticSize = Enum.AutomaticSize.XY,
		Content = {
			props.Text and baseText({
				Name = "Text",
				Appearance = useColor("Text", true),
				Text = props.Text,
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = 1,
			}),
			props.Icon and baseIcon({
				Name = "BadgeIcon",
				Icon = props.Icon,
				Color = useColor("Text", true),
				LayoutOrder = 0,
			}),
			props.TrailingIcon and baseIcon({
				Name = "BadgeTrailingIcon",
				Icon = props.TrailingIcon,
				Color = useColor("Text", true),
				LayoutOrder = 2,
			}),
			props.Content and New("Frame")({
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = 2,
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
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "Frame")) :: Frame
end

return badge
