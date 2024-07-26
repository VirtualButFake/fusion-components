local fusion = require("@packages/fusion")

local Children = fusion.Children
local Hydrate = fusion.Hydrate
local New = fusion.New

local Clean = fusion.cleanup
local Computed = fusion.Computed
local ForPairs = fusion.ForPairs
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use
local propertyProvider = fusionUtils.propertyProvider

local theme = require("@src/theme")

local element = require("./element")

local sinkFrame = require("@components/base/sinkFrame")
local baseFrame = require("@components/base/frame")

type props = {
	Color: fusion.CanBeState<string>,
	Variant: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Tabs: fusion.CanBeState<{
		{
			Label: string,
			Disabled: fusion.CanBeState<boolean>?,
			Content: fusion.CanBeState<{ any }>,
		}
	}>,
	DefaultIndex: number?,
	SelectedIndex: fusion.Value<number>?,
	OnSelect: ((index: number) -> nil)?,
}

local function tabs(props: props): Frame
	local useColor = theme:get("tabs", props.Color, props.Variant, "Container", props.AppearanceOverride)

	local selectedIndex = props.SelectedIndex or Value(props.DefaultIndex or 1)

	local sizePerTab = Computed(function()
		return 1 / #use(props.Tabs)
	end)

	local component = sinkFrame({
		Name = "TabMain",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Content = {
			New("UIListLayout")({
				VerticalAlignment = Enum.VerticalAlignment.Top,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			sinkFrame({
				Name = "Topbar",
				Appearance = useColor("Background", true),
				Stroke = useColor("Stroke", true),
				Size = UDim2.new(1, 0, 0, 36),
				Content = {
					baseFrame({
						Name = "Container",
						Padding = {
							Top = UDim.new(0, 4),
							Bottom = UDim.new(0, 4),
							Left = UDim.new(0, 4),
							Right = UDim.new(0, 4),
						},
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						Content = {
							New("Frame")({
								Name = "TabList",
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								[Children] = {
									New("UIListLayout")({
										FillDirection = Enum.FillDirection.Horizontal,
										HorizontalAlignment = Enum.HorizontalAlignment.Center,
										Padding = UDim.new(0, 6),
										VerticalAlignment = Enum.VerticalAlignment.Center,
									}),
									ForPairs(props.Tabs, function(index, value)
										local usedValue = use(value)

										return index,
											element({
												Color = props.Color,
												Variant = props.Variant,
												AppearanceOverride = props.AppearanceOverride,
												Label = usedValue.Label,
												Index = index,
												SelectedIndex = selectedIndex,
												SizePer = sizePerTab,
												Disabled = usedValue.Disabled,
												OnSelect = props.OnSelect,
											})
									end, Clean),
								},
							}),
						},
					}),
				},
			}),
			baseFrame({
				Name = "Content",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 36),
				Size = UDim2.new(1, 0, 0, 0),
				LayoutOrder = 2,
				AutomaticSize = Enum.AutomaticSize.Y,
				[Children] = {
					New("UIFlexItem")({
						FlexMode = Enum.UIFlexMode.Fill,
					}),
					Computed(function()
						local tab = use(props.Tabs)[selectedIndex:get()]

						return tab and tab.Content or {}
					end, Clean),
				},
			}),
		},
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "Frame"))
end

return tabs
