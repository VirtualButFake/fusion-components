local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local Computed = fusion.Computed

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use

local theme = require("@src/theme")

local meterBar = require("./meterBar")

local baseText = require("@components/base/text")
local baseIcon = require("@components/base/icon")

type props = {
	Label: meterBar.label,
	Percentage: fusion.Computed<number>,
	IconOffset: boolean,
}

local function meterLabel(props: props)
	local useColor = theme:get("bar", props.Label.Color, "default", "Base", props.Label.AppearanceOverride)

	return New("Frame")({
		Name = use(props.Label.Label),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		[Children] = props.Label.Slot and props.Label.Slot(useColor) or {
			New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			props.IconOffset and New("Frame")({
				Name = "IconSlot",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = 0,
				Size = UDim2.new(0, 16, 0, 16),
				[Children] = {
					props.Label.Icon and baseIcon({
						Icon = props.Label.Icon,
						Color = useColor("Highlight", true),
					}),
				},
			}),
			baseText({
				Appearance = useColor("Highlight", true),
				Text = Computed(function()
					return `{use(props.Label.Label)} ({use(props.Percentage)})`
				end),
				AutomaticSize = Enum.AutomaticSize.XY,
			}),
		},
	})
end

return meterLabel
