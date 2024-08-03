local fusion = require("@packages/fusion")
local Children = fusion.Children
local Hydrate = fusion.Hydrate
local New = fusion.New

local fusionUtils = require("@packages/fusionUtils")
local propertyProvider = fusionUtils.propertyProvider
local use = fusionUtils.use

local theme = require("@src/theme")

local baseIcon = require("@components/base/icon")
local baseFrame = require("@components/base/frame")
local baseText = require("@components/base/text")

type props = {
	Color: fusion.CanBeState<string>,
	Variant: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Title: fusion.CanBeState<string | baseText.text>,
	Description: fusion.CanBeState<string | baseText.text>?,
	Icon: baseIcon.icon? | string?,
	Slots: {
		Title: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
		Description: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
		LeadingContent: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
		TrailingContent: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?, -- right aligned content
		BottomContent: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
	}?,
}

local function alert(props: props): Frame
	local useColor = theme:get("alert", props.Color, props.Variant, "Base", props.AppearanceOverride)

	local component = baseFrame({
		Name = "Alert",
		Appearance = useColor("Background", true),
		Stroke = useColor("Stroke", true),
		Padding = UDim.new(0, 8),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Content = {
			New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			New("Frame")({
				Name = "ListContent",
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				[Children] = {
					New("UIFlexItem")({
						FlexMode = Enum.UIFlexMode.Shrink,
					}),
					New("UIListLayout")({
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Top,
					}),
					New("Frame")({
						Name = "ContainerMain",
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						[Children] = {
							New("UIListLayout")({
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Left,
								Padding = UDim.new(0, 8),
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Top,
							}),
							(props.Slots and props.Slots.LeadingContent or props.Icon) and New("Frame")({
								Name = "LeadingContent",
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1,
								[Children] = {
									props.Slots
											and props.Slots.LeadingContent
											and props.Slots.LeadingContent(useColor)
										or baseIcon({
											Icon = {
												Name = props.Icon,
												Size = 16,
											},
											Color = useColor("Title", true),
											Size = UDim2.new(0, 16, 0, 16),
										})
										or nil,
								},
							}) or nil,
							New("Frame")({
								Name = "TextContainer",
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1,
								[Children] = {
									New("UIListLayout")({
										FillDirection = Enum.FillDirection.Vertical,
										HorizontalAlignment = Enum.HorizontalAlignment.Left,
										Padding = UDim.new(0, 2),
										SortOrder = Enum.SortOrder.LayoutOrder,
										VerticalAlignment = Enum.VerticalAlignment.Top,
									}),
									(props.Slots and props.Slots.Title and props.Slots.Title(useColor))
										or baseText({
											Appearance = useColor("Title", true),
											Text = props.Title,
											AutomaticSize = Enum.AutomaticSize.XY,
											FontFace = Font.new(
												use(theme.global.font).Family,
												Enum.FontWeight.SemiBold
											),
											TextSize = typeof(props.Title) == "string" and 16 or nil,
											TextXAlignment = Enum.TextXAlignment.Left,
											TextYAlignment = Enum.TextYAlignment.Top,
											TextWrapped = true,
										})
										or nil,
									(
										props.Description
											and ((props.Slots and props.Slots.Description and props.Slots.Description(
												useColor
											)) or baseText({
												Appearance = useColor("Description", true),
												Text = props.Description,
												AutomaticSize = Enum.AutomaticSize.XY,
												FontFace = theme.global.font,
												TextSize = typeof(props.Description) == "string" and 14 or nil,
												TextXAlignment = Enum.TextXAlignment.Left,
												TextYAlignment = Enum.TextYAlignment.Top,
												TextWrapped = true,
											}))
										or nil
									),
								},
							}),
						},
					}),
					props.Slots and props.Slots.BottomContent and New("Frame")({
						Name = "BottomContent",
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						[Children] = {
							props.Slots and props.Slots.BottomContent and props.Slots.BottomContent(useColor),
						},
					}) or nil,
				},
			}),
			props.Slots and props.Slots.TrailingContent and New("Frame")({
				Name = "TrailingContent",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				[Children] = {
					props.Slots.TrailingContent(useColor),
				},
			}) or nil,
		},
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "Frame"))
end

return alert
