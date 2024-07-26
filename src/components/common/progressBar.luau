local RunService = game:GetService("RunService")

local fusion = require("@packages/fusion")
local Spring = fusion.Spring

local Children = fusion.Children
local cleanup = fusion.Cleanup
local Hydrate = fusion.Hydrate
local New = fusion.New

local Computed = fusion.Computed
local Observer = fusion.Observer
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use
local propertyProvider = fusionUtils.propertyProvider
local getState = fusionUtils.getState

local theme = require("@src/theme")

local baseFrame = require("@components/base/frame")
local baseText = require("@components/base/text")

local function easeInOutCubic(x: number): number
	return x < 0.5 and 4 * x * x * x or 1 - math.pow(-2 * x + 2, 3) / 2
end

local function interpolate(a: number, b: number, t: number): number
	return a + (b - a) * t
end

type props = {
	Color: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Height: fusion.CanBeState<UDim>?,
	Progress: fusion.CanBeState<number>?,
	Max: fusion.CanBeState<number>?,
	Indeterminate: fusion.CanBeState<boolean>?,
	Indicator: fusion.CanBeState<boolean>?,
	Slots: {
		Indicator: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
	}?,
}

local INDETERMINATE_SPEED = 1.5

local function progressBar(props: props): Frame
	local useColor = theme:get("bar", props.Color, "default", "Base", props.AppearanceOverride)

	local disconnectIndeterminate
	local getIndeterminateTransparency
	local indeterminateConnection

	if props.Indeterminate then
		local indeterminateClock = Value(0)

		local function setupIndeterminate()
			indeterminateConnection = RunService.RenderStepped:Connect(function(dt)
				indeterminateClock:set(indeterminateClock:get() + dt)
			end)
		end

		if typeof(props.Indeterminate) == "table" then
			disconnectIndeterminate = Observer(props.Indeterminate):onChange(function()
				if use(props.Indeterminate) then
					setupIndeterminate()
				else
					if indeterminateConnection then
						indeterminateConnection:Disconnect()
						indeterminateConnection = nil
					end
				end
			end)
		end

		if use(props.Indeterminate) then
			setupIndeterminate()
		end

		function getIndeterminateTransparency()
			local easePosition = interpolate(
				-0.075,
				1.075,
				easeInOutCubic(indeterminateClock:get() % INDETERMINATE_SPEED / INDETERMINATE_SPEED)
			)

			local width = 0.225 * easeInOutCubic(1 - math.abs(easePosition - 0.5))
			local startPosition = math.clamp(easePosition - width, 0, 1)
			local endPosition = math.clamp(easePosition + width, 0, 1)

			local keypoints = {}

			if startPosition - 0.001 <= 0 then
				table.insert(keypoints, NumberSequenceKeypoint.new(0, 0))
			else
				table.insert(keypoints, NumberSequenceKeypoint.new(0, 1))
				table.insert(keypoints, NumberSequenceKeypoint.new(startPosition - 0.001, 1))
				table.insert(keypoints, NumberSequenceKeypoint.new(startPosition, 0))
			end

			if endPosition + 0.001 >= 1 then
				table.insert(keypoints, NumberSequenceKeypoint.new(1, 0))
			else
				table.insert(keypoints, NumberSequenceKeypoint.new(endPosition, 0))
				table.insert(keypoints, NumberSequenceKeypoint.new(endPosition + 0.001, 1))
				table.insert(keypoints, NumberSequenceKeypoint.new(1, 1))
			end

			return NumberSequence.new(keypoints)
		end
	end

	local progressSpring = Spring(getState(props.Progress), 22, 1)

	local component = New("Frame")({
		Name = "ProgressBarContainer",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		[cleanup] = { disconnectIndeterminate, indeterminateConnection },
		[Children] = {
			props.Indicator and New("UIListLayout")({
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			props.Indicator and not props.Indeterminate and New("Frame")({
				Name = "IndicatorContainer",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				[Children] = {
					New("Frame")({
						Name = "Indicator",
						AnchorPoint = Vector2.new(0.5, 0),
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						Position = Spring(
							Computed(function()
								local progress = use(props.Progress) or 0
								local max = use(props.Max) or 1

								return UDim2.new(progress / max, 0, 0, 0)
							end),
							22,
							1
						),
						[Children] = props.Slots and props.Slots.Indicator and props.Slots.Indicator(useColor) or {
							baseText({
								Appearance = useColor("Indicator", true),
								Text = Computed(function()
									local progress = use(props.Progress) or 0
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
					baseFrame({
						Name = "HighlightBar",
						Appearance = useColor("Highlight", true),
						Content = {
							New("UIGradient")({
								Transparency = Computed(function()
									if not props.Indeterminate then
										-- transparency should go up to the value of the progress
										local progress = (progressSpring:get() or 0) / (use(props.Max) or 1)
										local progressOffset = progress - 0.001

										local keypoints = {
											NumberSequenceKeypoint.new(0, progressOffset < 0 and 0 or 0),
											NumberSequenceKeypoint.new(
												progressOffset > 0 and progressOffset or 0.001,
												0
											),
										}

										if progress < 1 then
											table.insert(
												keypoints,
												NumberSequenceKeypoint.new(math.max(progress, 0.0011), 1)
											)
											table.insert(keypoints, NumberSequenceKeypoint.new(1, 1))
										end

										return NumberSequence.new(keypoints)
									end

									return getIndeterminateTransparency()
								end),
							}),
						},
						Size = UDim2.new(1, 0, 1, 0),
					}),
				},
				Size = Computed(function()
					local height = use(props.Height) or UDim.new(0, 8)
					return UDim2.new(1, 0, height.Scale, height.Offset)
				end),
			}),
		},
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "Frame"))
end

return progressBar
