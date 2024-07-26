local fusion = require("@packages/fusion")
local Spring = fusion.Spring

local Children = fusion.Children
local Hydrate = fusion.Hydrate
local New = fusion.New

local Clean = fusion.cleanup
local Computed = fusion.Computed
local ForPairs = fusion.ForPairs

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use
local propertyProvider = fusionUtils.propertyProvider

local theme = require("@src/theme")

local meterBar = require("./meterBar")
local meterLabel = require("./meterLabel")

local baseFrame = require("@components/base/frame")
local baseText = require("@components/base/text")

type props = {
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Height: fusion.CanBeState<UDim>?,
	Max: fusion.CanBeState<number>?,
	Indicator: fusion.CanBeState<boolean>?,
	Labels: fusion.CanBeState<{ meterBar.label }>,
	Slots: {
		Indicator: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
	}?,
}

local function meter(props: props): Frame
	local useColor = theme:get("bar", "gray", "default", "Base", props.AppearanceOverride)
	local cumulativeProgressAll = Computed(function()
		local cumulativeProgress = 0

		for _, label in use(props.Labels) or {} do
			cumulativeProgress = cumulativeProgress + use(label.Value)
		end

		return cumulativeProgress
	end)

	local component = New("Frame")({
		Name = "MeterContainer",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		[Children] = {
			New("UIListLayout")({
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			props.Indicator and New("Frame")({
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				[Children] = {
					New("Frame")({
						Name = "Indicator",
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						Position = Spring(
							Computed(function()
								return UDim2.new(cumulativeProgressAll:get() / (use(props.Max) or 1), 0, 0, 0)
							end),
							22,
							1
						),
						[Children] = props.Slots and props.Slots.Indicator and props.Slots.Indicator(useColor) or {
							baseText({
								Appearance = useColor("Indicator", true),
								Text = Computed(function()
									local progress = cumulativeProgressAll:get()
									local max = use(props.Max) or 1

									return string.format("%.0f%%", progress / max * 100)
								end),
								AutomaticSize = Enum.AutomaticSize.XY,
							}),
						},
					}),
				},
			}) or nil,
			baseFrame({
				Name = "ProgressBar",
				Appearance = useColor("Background", true),
				Content = {
					ForPairs(props.Labels, function(index, label)
						local cumulativeProgressForLabel = Computed(function()
							local cumulativeProgress = 0

							for i, iteratedLabel in use(props.Labels) or {} do
								if i < index then
									cumulativeProgress = cumulativeProgress + use(iteratedLabel.Value)
								end
							end

							return cumulativeProgress
						end)

						return index,
							meterBar({
								Label = label,
								Position = cumulativeProgressForLabel,
							})
					end, Clean),
				},
				Size = Computed(function()
					local height = use(props.Height) or UDim.new(0, 8)
					return UDim2.new(1, 0, height.Scale, height.Offset)
				end),
			}),
			Computed(function()
				local doesLabelWithLabelExist = false
				local doesLabelWithIconExist = false

				for _, label in use(props.Labels) or {} do
					if label.Label then
						doesLabelWithLabelExist = true
					end

					if label.Icon then
						doesLabelWithIconExist = true
					end

					if doesLabelWithLabelExist and doesLabelWithIconExist then
						break
					end
				end

				if doesLabelWithLabelExist then
					return New("Frame")({
						Name = "LabelList",
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						ClipsDescendants = true,
						Size = UDim2.new(1, 0, 0, 0),
						[Children] = {
							New("UIListLayout")({
								FillDirection = Enum.FillDirection.Vertical,
								HorizontalAlignment = Enum.HorizontalAlignment.Left,
								Padding = UDim.new(0, doesLabelWithIconExist and 4 or 0),
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Top,
							}),
							ForPairs(props.Labels, function(index, label)
								if label.Label == nil then
									return index, nil
								end

								return index,
									meterLabel({
										Label = label,
										Percentage = Computed(function()
											local progress = use(label.Value)
											local max = use(props.Max) or 1

											return string.format("%.0f%%", progress / max * 100)
										end),
										IconOffset = doesLabelWithIconExist,
									})
							end, Clean),
						},
					})
				end

				return
			end, Clean),
		},
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "Frame"))
end

return meter
