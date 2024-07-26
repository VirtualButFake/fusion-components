local fusion = require("@packages/fusion")
local Spring = fusion.Spring

local Children = fusion.Children
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
	Value: fusion.CanBeState<number>?,
	Min: fusion.CanBeState<number>,
	Max: fusion.CanBeState<number>,
	Step: fusion.CanBeState<number>?,
	VisualizeSteps: fusion.CanBeState<boolean>?,
	Tooltip: boolean?,
	TooltipPlacement: placementPopover.placement?,
	InterceptChange: ((value: number) -> number)?,
	OnValueChanged: ((value: number) -> nil)?,
	OnDrag: ((state: boolean) -> nil)?,
	Slots: {
		Handle: ((
			useColor: theme.useColorFunction,
			percentage: fusion.Computed<number>
		) -> fusion.CanBeState<{ any }>)?,
		Tooltip: ((useColor: theme.useColorFunction, value: fusion.Value<number>) -> fusion.CanBeState<{ any }>)?,
		BarBase: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
		BarFill: ((useColor: theme.useColorFunction, percentage: fusion.Value<number>) -> fusion.CanBeState<{ any }>)?,
	}?,
}

local function slider(props: props): Frame
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

	local handleAbsoluteSize = Value(Vector2.new())
	local containerPosition = Value(Vector2.new())
	local containerSize = Value(Vector2.new())
	local mousePosition = Value(Vector2.new())

	local handle = Value()

	local sliderValue = getState(props.Value and use(props.Value) or use(props.Min))

	local updateSliderValue

	if typeof(props.Value) == "table" then
		updateSliderValue = Observer(props.Value):onChange(function()
			sliderValue:set(props.Value:get())
		end)
	end

	local disconnectValueUpdateObserver = Observer(Computed(function()
		return use(isDragging) and use(mousePosition) or nil
	end)):onChange(function()
		if not use(isDragging) then
			if wasDragging then
				wasDragging = false
				if props.OnDrag then
					props.OnDrag(false, sliderValue:get())
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

		if newValue ~= sliderValue:get() then
			sliderValue:set(newValue)

			if props.OnValueChanged then
				props.OnValueChanged(newValue)
			end
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
					props.Slots and props.Slots.BarFill and props.Slots.BarFill(useColor, Computed(function()  
                        local min = use(props.Min)
                        local max = use(props.Max)

                        return math.clamp((sliderValue:get() - min) / (max - min), 0, 1)
                    end)) or baseFrame({
						Name = "BarHighlight",
						Appearance = useColor("Highlight", true),
						CornerRadius = UDim.new(1, 0),
						Content = {
							New("UIGradient")({
								Offset = Spring(
									Computed(function()
										local percentage = math.clamp(
											(sliderValue:get() - use(props.Min)) / (use(props.Max) - use(props.Min)),
											0,
											1
										)

										if use(containerSize) then
											local absoluteSize = use(containerSize)
											local currentHandleAbsoluteSize = use(handleAbsoluteSize)
											local centeredPercentage = percentage - 0.5
											local pxOffset = currentHandleAbsoluteSize.X / 2 * (centeredPercentage * 2)
											local scaledOffset = pxOffset / absoluteSize.X

											if scaledOffset ~= scaledOffset then
												return Vector2.new(-1 + percentage, 0)
											end

											return Vector2.new(-1 + percentage - scaledOffset, 0)
										end

										return Vector2.new(-1 + percentage, 0)
									end),
									30,
									1
								),
								Transparency = NumberSequence.new({
									NumberSequenceKeypoint.new(0, 0),
									NumberSequenceKeypoint.new(0.999, 0),
									NumberSequenceKeypoint.new(1, 0.999),
								}),
							}),
						},
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 3,
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
							props.Slots and props.Slots.Handle and Computed(function()
								local component = use(props.Slots.Handle)(
									useColor,
									Computed(function()
										local min = use(props.Min)
										local max = use(props.Max)
										local percentage = math.clamp((sliderValue:get() - min) / (max - min), 0, 1)
										return percentage
									end)
								)

								handle:set(component)

								local changedConnection = component
									:GetPropertyChangedSignal("AbsoluteSize")
									:Connect(function()
										handleAbsoluteSize:set(component.AbsoluteSize)
									end)

								handleAbsoluteSize:set(component.AbsoluteSize)

								onDestroy(component, { changedConnection })

								return component
							end, Clean) or baseFrame({
								Name = "Handle",
								Appearance = useColor("Handle", true),
								CornerRadius = UDim.new(1, 0),
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = Spring(
									Computed(function()
										local min = use(props.Min)
										local max = use(props.Max)
										local percentage = math.clamp((sliderValue:get() - min) / (max - min), 0, 1)
										return UDim2.new(percentage, 0, 0.5, 0)
									end),
									30,
									1
								),
								Size = handleSize,
								ZIndex = 3,
								[Out("AbsoluteSize")] = handleAbsoluteSize,
								[Ref] = handle,
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
			if isHovering:get() then
				return true
			end

			if isDragging:get() then
				return checkInputRange()
			end

			return
		end),
		OnMouseButton1Changed = function(state)
			isDragging:set(state)

			if state and props.OnDrag then
				props.OnDrag(true, sliderValue:get())
			end
		end,
	})

	awaitLayer(sliderComponent, function(layer)
		if props.Tooltip then
			tooltip(use(handle), {
				Variant = "default",
				AppearanceOverride = props.TooltipAppearanceOverride,
				Placement = props.TooltipPlacement or "top",
				Visible = Computed(function()
					return isHoveringHandle:get() or isDragging:get()
				end),
				DisableHoverBehaviour = true,
				Slots = {
					Content = props.Slots and props.Slots.Tooltip and props.Slots.Tooltip(useColor, sliderValue)
						or function(useSlotColor)
							return baseText({
								Appearance = useSlotColor("Text", true),
								Text = Computed(function()
									return tostring(math.round(sliderValue:get() * 10) / 10)
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
			handle:get(false):GetPropertyChangedSignal("GuiState"):Connect(function()
				isHoveringHandle:set(handle:get().GuiState ~= Enum.GuiState.Idle)
			end),
			disconnectValueUpdateObserver,
			mouseDownUpdate,
			updateSliderValue,
		})
	end)

	return sliderComponent
end

return slider
