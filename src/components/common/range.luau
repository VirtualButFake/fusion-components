local fusion = require("@packages/fusion")
local Spring = fusion.Spring

local Children = fusion.Children
local Cleanup = fusion.Cleanup
local New = fusion.New
local Out = fusion.Out
local Ref = fusion.Ref

local Clean = fusion.cleanup
local Computed = fusion.Computed
local ForPairs = fusion.ForPairs
local Observer = fusion.Observer
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local awaitLayer = fusionUtils.awaitLayer
local use = fusionUtils.use
local getState = fusionUtils.getState
local onDestroy = fusionUtils.onDestroy

local theme = require("@src/theme")

local baseText = require("@components/base/text")
local baseFrame = require("@components/base/frame")
local baseButton = require("@components/base/button")

local inputCollector = require("@components/utility/inputCollector")
local tooltip = require("@components/common/tooltip")
local placementPopover = require("@components/utility/placementPopover")

type props = {
	Color: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	TooltipAppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Disabled: fusion.CanBeState<boolean>?,
	BarHeight: fusion.CanBeState<UDim>?, -- defaults to 0, 8
	HandleSize: fusion.CanBeState<UDim2>?, -- defaults to 0, 16, 0, 16
	Width: fusion.CanBeState<UDim>?,
	Value: fusion.CanBeState<{ fusion.CanBeState<number> }>?,
	Min: fusion.CanBeState<number>,
	Max: fusion.CanBeState<number>,
	VisualizeSteps: fusion.CanBeState<boolean>?,
	Step: fusion.CanBeState<number>?,
	Tooltip: boolean?,
	TooltipPlacement: placementPopover.placement?,
	InterceptChange: ((value: { number }) -> { number })?,
	OnValueChanged: ((index: number, value: number) -> nil)?,
	OnDrag: ((state: boolean, values: { fusion.Value<number> }) -> nil)?,
	Slots: {
		Handle: ((useColor: theme.useColorFunction, percentage: fusion.Value<number>) -> fusion.CanBeState<{ any }>)?,
		Tooltip: ((useColor: theme.useColorFunction, value: { fusion.Value<number> }) -> fusion.CanBeState<{ any }>)?,
		BarBase: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
		BarFill: ((
			useColor: theme.useColorFunction,
			percentages: { fusion.Value<number> }
		) -> fusion.CanBeState<{ any }>)?,
	}?,
}

local function range(props: props): Frame
	local isHovering = Value(false)
	local isDragging = Value(false)
	local isHoveringHandle = Value(false)

	local wasDragging = false

	local useColor = theme:get(
		"slider",
		props.Color,
		"default",
		Computed(function()
			if use(props.Disabled) then
				return "Disabled"
			elseif use(isHovering) or use(isDragging) then
				return "Hover"
			else
				return "Base"
			end
		end),
		props.AppearanceOverride
	)

	local barSize = props.BarHeight
			and Computed(function()
				local barHeight = use(props.BarHeight)

				return UDim2.new(1, 0, barHeight.Scale, barHeight.Offset)
			end)
		or UDim2.new(1, 0, 0, 8)

	local handleSize = props.HandleSize or UDim2.new(0, 16, 0, 16)

	local containerPosition = Value(Vector2.new())
	local containerSize = Value(Vector2.new())
	local mousePosition = Value(Vector2.new())

	local barHighlight: fusion.Value<Frame> = Value()

	local sliderValues = {
		getState(props.Value and use(props.Value)[1] or nil or use(props.Min)),
		getState(props.Value and use(props.Value)[2] or nil or use(props.Max)),
	}

	local tweenedValues = { Spring(sliderValues[1], 22, 1), Spring(sliderValues[2], 22, 1) }

	local updateValueObservers = {}

	if props.Value and typeof(use(props.Value)[1]) == "table" and typeof(use(props.Value)[2]) == "table" then
		for i = 1, 2 do
			updateValueObservers[i] = Observer(use(props.Value)[i]):onChange(function()
				sliderValues[i]:set(use(props.Value)[i])
			end)
		end
	elseif props.Value and typeof(use(props.Value)) == "table" and (props.Value :: any).get then
		updateValueObservers[1] = Observer(props.Value):onChange(function()
			local usedValue = use(props.Value)
			sliderValues[1]:set(usedValue[1])
			sliderValues[2]:set(usedValue[2])
		end)
	end

	local disconnectValueUpdateObserver = Observer(Computed(function()
		return use(isDragging) and use(mousePosition) or nil
	end)):onChange(function()
		if not use(isDragging) then
			if wasDragging then
				wasDragging = false
				if props.OnDrag then
					props.OnDrag(false, { sliderValues[1]:get(), sliderValues[2]:get() })
				end
			end

			return
		end

		wasDragging = true

		local currentHandleSize = use(handleSize)
		local padSize = (currentHandleSize.X.Scale * use(containerSize).X) / 2 + currentHandleSize.X.Offset / 2
		local scaledMousePosition = (use(mousePosition).X - use(containerPosition).X) / use(containerSize).X

		-- overcomplicated? absolutely.
		local paddingPrediction = (scaledMousePosition - 0.5) * padSize * 2
		scaledMousePosition += paddingPrediction / use(containerSize).X

		local min = use(props.Min)
		local max = use(props.Max)
		local step = use(props.Step)

		local percentage = math.clamp(scaledMousePosition, 0, 1)

		local newValue = min + (max - min) * percentage

		if step then
			local closestStep = math.round((newValue - min) / step) * step + min

			if closestStep <= max and closestStep >= min then
				newValue = closestStep
			else
				local roundingFunction = closestStep < min and math.ceil or math.floor
				newValue = roundingFunction((newValue - min) / step) * step + min
			end
		end

		if props.InterceptChange then
			newValue = props.InterceptChange(newValue) or newValue
		end

		if isDragging:get() == 1 then
			sliderValues[1]:set(math.clamp(newValue, min, sliderValues[2]:get()))
		else
			sliderValues[2]:set(math.clamp(newValue, sliderValues[1]:get(), max))
		end

		if props.OnValueChanged then
			props.OnValueChanged(isDragging:get(), sliderValues[isDragging:get()]:get())
		end
	end)

	local sliderComponent = New("Frame")({
		Name = "SliderContainer",
		BackgroundTransparency = 1,
		Size = Computed(function()
			local currentHandleSize = use(handleSize)
			local width = use(props.Width) or UDim.new(1, 0)

			return UDim2.new(width.Scale, width.Offset, currentHandleSize.Y.Scale, currentHandleSize.Y.Offset)
		end),
		[Out("AbsolutePosition")] = containerPosition,
		[Out("AbsoluteSize")] = containerSize,
		[Cleanup] = {
			disconnectValueUpdateObserver,
			updateValueObservers,
		},
		[Children] = {
			baseButton({
				Name = "Bar",
				CornerRadius = 0,
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				DisableHoverLighting = true,
				OnHover = function(state)
					isHovering:set(state)
				end,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = barSize,
				[Children] = {
					props.Slots and props.Slots.BarBase and props.Slots.BarBase(useColor) or baseFrame({
						Name = "BaseBar",
						Appearance = useColor("Background", true),
						CornerRadius = UDim.new(1, 0),
						Size = UDim2.new(1, 0, 1, 0),
					}),
					props.Slots and props.Slots.BarFill and props.Slots.BarFill(
						useColor,
						Computed(function()
							local min = use(props.Min)
							local max = use(props.Max)

							return {
								math.clamp((tweenedValues[1]:get() - min) / (max - min), 0, 1),
								math.clamp((tweenedValues[2]:get() - min) / (max - min), 0, 1),
							}
						end)
					) or baseFrame({
						Name = "BarHighlight",
						Appearance = useColor("Highlight", true),
						CornerRadius = UDim.new(1, 0),
						Content = {
							New("UIGradient")({
								Transparency = Computed(function()
									local pointA = tweenedValues[1]:get()
									local pointB = tweenedValues[2]:get()

									local percentageA =
										math.clamp((pointA - use(props.Min)) / (use(props.Max) - use(props.Min)), 0, 1)
									local percentageB =
										math.clamp((pointB - use(props.Min)) / (use(props.Max) - use(props.Min)), 0, 1)

									local largestPercentage = math.max(percentageA, percentageB)
									local smallestPercentage = math.min(percentageA, percentageB)

									local keyPoints = {
										NumberSequenceKeypoint.new(0, smallestPercentage < 0.001 and 0 or 1),
										NumberSequenceKeypoint.new(math.clamp(smallestPercentage - 0.001, 0, 1), 1),
										NumberSequenceKeypoint.new(smallestPercentage, 0),
										NumberSequenceKeypoint.new(largestPercentage, 0),
									}

									if largestPercentage < 0.999 then
										table.insert(
											keyPoints,
											NumberSequenceKeypoint.new(largestPercentage + 0.001, 1)
										)
									end

									if largestPercentage ~= 1 then
										table.insert(
											keyPoints,
											NumberSequenceKeypoint.new(1, largestPercentage < 0.999 and 1 or 0)
										)
									end

									return NumberSequence.new(keyPoints)
								end),
							}),
						},
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 3,
						[Ref] = barHighlight,
					}),
					New("Frame")({
						Name = "PaddedContent",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						[Children] = {
							Computed(function()
								local currentHandleSize = use(handleSize)
								local padSize = UDim.new(currentHandleSize.X.Scale / 2, currentHandleSize.X.Offset / 2)

								return New("UIPadding")({
									PaddingLeft = padSize,
									PaddingRight = padSize,
								})
							end, Clean),
							props.VisualizeSteps and Computed(function()
								if use(props.VisualizeSteps) then
									local stepTable = {}

									local min = use(props.Min)
									local max = use(props.Max)
									local step = use(props.Step)

									if not step then
										return nil
									end

									for i = min, max, step do
										table.insert(stepTable, i)
									end

									local currentBarSize = use(barSize)
									local stepSize = UDim2.new(
										currentBarSize.Y.Scale / 2,
										currentBarSize.Y.Offset / 2,
										currentBarSize.Y.Scale / 2,
										currentBarSize.Y.Offset / 2
									)

									return New("Frame")({
										Name = "Steps",
										BackgroundTransparency = 1,
										Size = UDim2.new(1, 0, 1, 0),
										ZIndex = 2,
										[Children] = ForPairs(stepTable, function(index, value)
											return index,
												baseFrame({
													Name = "Step",
													Appearance = useColor("Step", true),
													CornerRadius = UDim.new(1, 0),
													AnchorPoint = Vector2.new(0.5, 0.5),
													Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
													Size = stepSize,
													[Children] = {
														New("UIAspectRatioConstraint")({}),
													},
												})
										end, Clean),
									})
								end

								return
							end, Clean),
							props.Slots and props.Slots.Handle and props.Slots.Handle(
								useColor,
								Computed(function()
									local min = use(props.Min)
									local max = use(props.Max)
									return math.clamp((sliderValues[1]:get() - min) / (max - min), 0, 1)
								end)
							) or baseFrame({
								Name = "Handle",
								Appearance = useColor("Handle", true),
								CornerRadius = UDim.new(1, 0),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = Spring(
									Computed(function()
										local min = use(props.Min)
										local max = use(props.Max)
										local percentage = math.clamp((sliderValues[1]:get() - min) / (max - min), 0, 1)
										return UDim2.new(percentage, 0, 0.5, 0)
									end),
									30,
									1
								),
								Size = handleSize,
								ZIndex = 3,
							}),
							props.Slots and props.Slots.Handle and props.Slots.Handle(
								useColor,
								Computed(function()
									local min = use(props.Min)
									local max = use(props.Max)
									return math.clamp((sliderValues[2]:get() - min) / (max - min), 0, 1)
								end)
							) or baseFrame({
								Name = "Handle",
								Appearance = useColor("Handle", true),
								CornerRadius = UDim.new(1, 0),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = Spring(
									Computed(function()
										local min = use(props.Min)
										local max = use(props.Max)
										local percentage = math.clamp((sliderValues[2]:get() - min) / (max - min), 0, 1)
										return UDim2.new(percentage, 0, 0.5, 0)
									end),
									30,
									1
								),
								Size = handleSize,
								ZIndex = 3,
							}),
						},
					}),
				},
			}),
		},
	})

	local function checkInputRange()
		local size = use(containerSize)
		local mousePos = use(mousePosition)
		local distance = mousePos - use(containerPosition) - size / 2
		local horizontalDistance = math.abs(distance.X)
		local verticalDistance = math.abs(distance.Y)

		if horizontalDistance < size.X / 2 + 48 and verticalDistance < size.Y / 2 + 48 then
			return true
		end

		return false
	end

	inputCollector({
		ReferenceObject = sliderComponent,
		Visible = Computed(function()
			if isDragging:get() then
				local isInRange = checkInputRange()

				if not isInRange then
					isDragging:set(false)
				end

				return isInRange
			end

			if isHovering:get() then
				return true
			end

			return
		end),
		OnMouseButton1Changed = function(state)
			if state then
				local currentMousePosition = use(mousePosition)
				local absolutePosition, absoluteSize = use(containerPosition), use(containerSize)

				-- find side of the slider the mouse is closest to
				local min = use(props.Min)
				local max = use(props.Max)

				local distanceFromContainer = currentMousePosition.X - absolutePosition.X

				local distanceFromValue1 = math.abs(
					math.clamp((tweenedValues[1]:get() - min) / (max - min), 0, 1) * absoluteSize.X
						- distanceFromContainer
				)
				local distanceFromValue2 = math.abs(
					math.clamp((tweenedValues[2]:get() - min) / (max - min), 0, 1) * absoluteSize.X
						- distanceFromContainer
				)

				local distanceDifference = math.abs(distanceFromValue1 - distanceFromValue2)

				if distanceDifference < 0.01 then
					-- this is necessary in case we're on the far edge of either side. the user could get locked into one of the handles and not be able to move the other, which is VERY annoying
					-- the below statement could work with either value since the difference is negligible regardless
					if math.clamp((tweenedValues[1]:get() - min) / (max - min), 0, 1) > 0.5 then
						-- default to 1
						isDragging:set(1)
						return
					else
						-- default to 2
						isDragging:set(2)
						return
					end
				end

				isDragging:set(distanceFromValue1 < distanceFromValue2 and 1 or 2)
			else
				isDragging:set(false)
			end

			if state and props.OnDrag then
				props.OnDrag(true, { sliderValues[1]:get(), sliderValues[2]:get() })
			end
		end,
	})

	awaitLayer(sliderComponent, function(layer)
		if props.Tooltip then
			tooltip(use(barHighlight), {
				Variant = "default",
				AppearanceOverride = props.TooltipAppearanceOverride,
				RelativePosition = Computed(function()
					local currentContainerSize = use(containerSize)

					if not currentContainerSize then
						return UDim2.new(0, 0, 0, 0)
					end

					local averageValue = (tweenedValues[1]:get() + tweenedValues[2]:get()) / 2
					local percentage =
						math.clamp((averageValue - use(props.Min)) / (use(props.Max) - use(props.Min)), 0, 1)

					return UDim2.new(0, percentage * currentContainerSize.X - currentContainerSize.X / 2, 0, 0)
				end),
				Placement = props.TooltipPlacement or "top",
				Visible = Computed(function()
					return isHoveringHandle:get() or isDragging:get()
				end),
				DisableHoverBehaviour = true,
				Slots = {
					Content = props.Slots and props.Slots.Tooltip and props.Slots.Tooltip(useColor, sliderValues)
						or function(useSlotColor)
							return baseText({
								Appearance = useSlotColor("Text", true),
								Text = Computed(function()
									return tostring(math.round(sliderValues[1]:get() * 10) / 10)
										.. " - "
										.. tostring(math.round(sliderValues[2]:get() * 10) / 10)
								end),
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1,
								TextSize = 14,
							})
						end,
				},
			})
		end

		local mouseDownUpdate = Observer(layer.state.mouseDown):onChange(function()
			if not layer.state.mouseDown:get() and not isHovering:get() then
				isDragging:set(false)
			end
		end)

		local mousePositionUpdate = Observer(layer.state.mousePosition):onChange(function()
			mousePosition:set(layer.state.mousePosition:get())
		end)

		onDestroy(sliderComponent, {
			mousePositionUpdate,
			disconnectValueUpdateObserver,
			mouseDownUpdate,
			disconnectValueUpdateObserver,
			barHighlight:get(false):GetPropertyChangedSignal("GuiState"):Connect(function()
				isHoveringHandle:set(barHighlight:get().GuiState ~= Enum.GuiState.Idle)
			end),
		})
	end)

	return sliderComponent
end

return range
