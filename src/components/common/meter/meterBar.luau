local fusion = require("@packages/fusion")
local Spring = fusion.Spring

local New = fusion.New
local Event = fusion.OnEvent

local Computed = fusion.Computed
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use

local theme = require("@src/theme")

local baseFrame = require("@components/base/frame")

type props = {
	Label: label,
	Position: fusion.Computed<number>,
}

export type label = {
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Value: fusion.CanBeState<number>,
	Label: fusion.CanBeState<string>?,
	Color: fusion.CanBeState<string>,
	Icon: fusion.CanBeState<string>?,
	Slot: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
}

local VALUE_DELTA = 0.001

local function meterBar(props: props)
	local useColor = theme:get("bar", props.Label.Color, "default", "Base", props.Label.AppearanceOverride)

	local position = Spring(props.Position, 20, 1)
	local value = Spring(props.Label.Value, 20, 1)

	local isHovering = Value(false)
	local isPressing = Value(false)

	return baseFrame({
		Name = "MeterBar",
		Appearance = Spring(
			Computed(function()
				local color = table.clone(useColor("Highlight"))

				if (isHovering:get() or isPressing:get()) and color.color then
					local h, s, v = Color3.toHSV(color.color)
					local multiplier = isPressing:get() and 1.2 or 1.1

					color.color = Color3.fromHSV(h, s, v * multiplier)
				end

				return color
			end),
			22,
			1
		),
		Content = {
			New("Frame")({
				-- a frame positioned in the area that the bar takes
				BackgroundTransparency = 1,
				Position = Computed(function()
					return UDim2.new(props.Position:get(), 0, 0, 0)
				end),
				Size = Computed(function()
					return UDim2.new(use(props.Label.Value), 0, 1, 0)
				end),
				[Event("MouseEnter")] = function()
					isHovering:set(true)
				end,
				[Event("MouseLeave")] = function()
					isHovering:set(false)
				end,
				[Event("InputBegan")] = function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						isPressing:set(true)
					end
				end,
				[Event("InputEnded")] = function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						isPressing:set(false)
					end
				end,
			}),
			New("UIGradient")({
				Transparency = Computed(function()
					local keypoints = {}

					local startPosition = position:get()
					local endPosition = startPosition + value:get()

					if startPosition > 1 or endPosition < 0 then
						return NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 1),
						})
					end

					if use(startPosition) - VALUE_DELTA <= 0 then
						table.insert(keypoints, NumberSequenceKeypoint.new(0, 0))
					else
						table.insert(keypoints, NumberSequenceKeypoint.new(0, 1))
						table.insert(keypoints, NumberSequenceKeypoint.new(use(startPosition) - VALUE_DELTA, 1))
						table.insert(keypoints, NumberSequenceKeypoint.new(use(startPosition), 0))
					end

					if use(endPosition) + VALUE_DELTA >= 1 then
						table.insert(keypoints, NumberSequenceKeypoint.new(1, 0))
					else
						table.insert(keypoints, NumberSequenceKeypoint.new(use(endPosition), 0))
						table.insert(keypoints, NumberSequenceKeypoint.new(use(endPosition) + VALUE_DELTA, 1))
						table.insert(keypoints, NumberSequenceKeypoint.new(1, 1))
					end

					return NumberSequence.new(keypoints)
				end),
			}),
		},
		Size = UDim2.new(1, 0, 1, 0),
	})
end

return meterBar
