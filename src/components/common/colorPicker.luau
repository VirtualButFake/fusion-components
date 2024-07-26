local fusion = require("@packages/fusion")
local Spring = fusion.Spring

local Children = fusion.Children
local Hydrate = fusion.Hydrate
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
local peek = fusionUtils.peek
local propertyProvider = fusionUtils.propertyProvider

local theme = require("@src/theme")

local baseFrame = require("@components/base/frame")
local baseButton = require("@components/base/button")

local slider = require("@components/common/slider")
local tabs = require("@components/common/tabs")
local inputCollector = require("@components/utility/inputCollector")
local input = require("@components/common/input")

local function resolveAppearance(baseAppearance: appearance, override: appearance | { [string]: any }): appearance
	return {
		Color = override.Color or baseAppearance.Color,
		Variant = override.Variant or baseAppearance.Variant,
		AppearanceOverride = override.AppearanceOverride or baseAppearance.AppearanceOverride,
	}
end

local function getColor3Distance(color1: Color3, color2: Color3): number
	return math.sqrt((color1.R - color2.R) ^ 2 + (color1.G - color2.G) ^ 2 + (color1.B - color2.B) ^ 2)
end

-- from https://devforum.roblox.com/t/a-journey-of-color-sorting/29876
local function ClampHue(h: number, segments: number)
	return math.floor(h * segments)
end

local function Luminosity(color: Color3)
	return math.sqrt((color.R * 0.299) ^ 2 + (0.587 * color.G) ^ 2 + (0.114 * color.B) ^ 2)
end

local function SortLuma(colorA, colorB)
	local hA = Color3.toHSV(colorA)
	local hB = Color3.toHSV(colorB)

	local clampedHA = ClampHue(hA, 4)
	local clampedHB = ClampHue(hB, 4)

	local lumA = Luminosity(colorA)
	local lumB = Luminosity(colorB)

	if clampedHA == clampedHB then
		return lumA < lumB
	else
		return clampedHA < clampedHB
	end
end

local brickColorMap = {}

for i = 1, 1032 do
	local color = BrickColor.new(i)

	if not table.find(brickColorMap, color.Color) then
		local foundCloseColor = false

		for _, existingColor in brickColorMap do
			if getColor3Distance(color.Color, existingColor) < 0.275 then
				foundCloseColor = true
				break
			end
		end

		if not foundCloseColor then
			table.insert(brickColorMap, color.Color)
		end
	end
end

table.sort(brickColorMap, function(a, b)
	return SortLuma(a, b)
end)

type appearance = {
	Color: fusion.CanBeState<string>,
	Variant: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
}

type props = {
	Color: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	TabsAppearance: appearance?,
	HidePalette: fusion.CanBeState<boolean>?,
	Value: fusion.CanBeState<Color3>?,
	PaletteColors: fusion.CanBeState<{ Color3 }>?,
	OnColorChange: ((color: Color3) -> nil)?,
	OnColorSet: ((color: Color3) -> nil)?,
	OnDragStart: ((color: Color3) -> nil)?,
	OnDragEnd: ((color: Color3) -> nil)?,
}

local HANDLE_SIZE = 16

local function colorPicker(props: props)
	local useColor = theme:get("colorPicker", props.Color, "default", "Base", props.AppearanceOverride)

	local tabsAppearance = resolveAppearance({
		Color = props.Color,
		Variant = "solid",
		AppearanceOverride = props.AppearanceOverride,
	}, props.TabsAppearance or {})

	-- hue, colorpickerx, colorpickery
	local colorVector = Value(Vector3.new(0, 0.5, 0.5))

	local colorValue = Computed(function()
		local vector = colorVector:get()
		local color = Color3.fromHSV(math.abs(vector.X - 1), vector.Y, 1 - vector.Z)

		-- round the color values (this *really* likes making 0.999999, which gets rounded down by a lot of roblox functions)
		color = Color3.new(
			math.round(color.R * 255) / 255,
			math.round(color.G * 255) / 255,
			math.round(color.B * 255) / 255
		)

		task.spawn(function()
			if props.OnColorChange then
				props.OnColorChange(color)
			end
		end)

		return color
	end)

	local lastSentColor = Value(colorValue:get())

	local function updateHandlesWithColor(color: Color3)
		if color == colorValue:get() then
			return
		end

		local h, s, v = Color3.toHSV(color)
		colorVector:set(Vector3.new(1 - h, s, 1 - v))
	end

	local pendingCleanup = {}

	if props.Value then
		updateHandlesWithColor(typeof(props.Value) == "Color3" and props.Value or peek(props.Value))

		local valueAsState = getState(props.Value)

		table.insert(
			pendingCleanup,
			Observer(valueAsState):onChange(function()
				updateHandlesWithColor(valueAsState:get())
			end)
		)
	end

	local colorPickerRef = Value(nil)
	local colorPickerSize = Value(Vector2.new())
	local colorPickerPosition = Value(Vector2.new())

	local colorPickerDown = Value(false)
	local colorPickerHover = Value(false)

	local hexInputText = Value("")
	local rInputText = Value("")
	local gInputText = Value("")
	local bInputText = Value("")

	local function updateColorWithRGB()
		local r = tonumber(rInputText:get())
		local g = tonumber(gInputText:get())
		local b = tonumber(bInputText:get())

		if r and g and b then
			updateHandlesWithColor(Color3.fromRGB(r, g, b))
		end
	end

	local picker = New("Frame")({
		Name = "ColorPickerContainer",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		[Children] = {
			New("UIPadding")({
				PaddingTop = UDim.new(0, 6),
			}),
			New("UIListLayout")({
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
			}),
			baseButton({
				Name = "ColorPicker",
				Stroke = useColor("Stroke", true),
				BackgroundTransparency = 1,
				OnHover = function(state)
					colorPickerHover:set(state)
				end,
				Size = UDim2.new(1, 0, 1, -52),
				[Out("AbsolutePosition")] = colorPickerPosition,
				[Out("AbsoluteSize")] = colorPickerSize,
				[Ref] = colorPickerRef,
				[Children] = {
					New("ImageLabel")({
						Name = "HSV",
						Image = "rbxassetid://17436025560",
						ImageColor3 = Computed(function()
							return Color3.fromHSV(math.abs(colorVector:get().X - 1), 1, 1)
						end),
						Size = UDim2.new(1, 0, 1, 0),
						[Children] = {
							New("UICorner")({
								CornerRadius = UDim.new(0, 4),
							}),
							New("UIGradient")({
								Color = ColorSequence.new({
									ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
									ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
								}),
								Rotation = 90,
							}),
						},
					}),
					New("Frame")({
						Name = "PaddedContent",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 4,
						[Children] = {
							New("UIPadding")({
								PaddingBottom = UDim.new(0, 8),
								PaddingLeft = UDim.new(0, 8),
								PaddingRight = UDim.new(0, 8),
								PaddingTop = UDim.new(0, 8),
							}),
							baseFrame({
								Name = "ColorPickerHandle",
								Appearance = useColor("SliderHandle", true),
								Stroke = Computed(function()
									local sliderHandleColor = useColor("SliderHandle")

									return { color = sliderHandleColor.color, transparency = 0 }
								end),
								CornerRadius = UDim.new(1, 0),
								AnchorPoint = Vector2.new(0.5, 0.5),
								BackgroundColor3 = colorValue,
								Position = Spring(
									Computed(function()
										local vector = colorVector:get()
										local xPercentage = vector.Y
										local yPercentage = vector.Z

										local pickerSize = use(colorPickerSize) or Vector2.new(1, 1)

										if pickerSize.X == 0 or pickerSize.Y == 0 then
											return UDim2.new(0.5, 0, 0.5, 0)
										end

										-- predict padding on both axes
										local paddingPredictionX = (xPercentage - 0.5) * HANDLE_SIZE / 2 * 2
										local paddingPredictionY = (yPercentage - 0.5) * HANDLE_SIZE / 2 * 2

										return UDim2.new(
											math.clamp(xPercentage + paddingPredictionX / pickerSize.X, 0, 1),
											0,
											math.clamp(yPercentage + paddingPredictionY / pickerSize.Y, 0, 1),
											0
										)
									end),
									45,
									1
								),
								Size = UDim2.new(0, HANDLE_SIZE, 0, HANDLE_SIZE),
							}),
						},
					}),
				},
			}),
			New("Frame")({
				Name = "HueSlider",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 16),
				[Children] = {
					slider({
						Color = "red",
						BarHeight = UDim.new(0, 8),
						Width = UDim.new(1, 0),
						Min = 0,
						Max = 1,
						Value = Computed(function()
							return colorVector:get().X
						end),
						OnValueChanged = function(value)
							colorVector:set(Vector3.new(value, colorVector:get().Y, colorVector:get().Z))
						end,
						OnDrag = function(dragging)
							if dragging then
								if props.OnDragStart then
									props.OnDragStart(colorValue:get())
								end
							else
								if props.OnDragEnd then
									props.OnDragEnd(colorValue:get())
								end

								if props.OnColorSet then
									props.OnColorSet(colorValue:get())
								end
							end
						end,
						Slots = {
							Handle = function(_, progress)
								local frame = baseFrame({
									Appearance = useColor("SliderHandle"),
									CornerRadius = UDim.new(1, 0),
									AnchorPoint = Vector2.new(0.5, 0.5),
									Content = {
										New("Frame")({
											AnchorPoint = Vector2.new(0.5, 0.5),
											BackgroundColor3 = Computed(function()
												return Color3.fromHSV(1 - progress:get(), 1, 1)
											end),
											Position = UDim2.new(0.5, 0, 0.5, 0),
											Size = UDim2.new(0.75, 0, 0.75, 0),
											[Children] = {
												New("UICorner")({
													CornerRadius = UDim.new(1, 0),
												}),
											},
										}),
									},
									Position = Spring(
										Computed(function()
											return UDim2.new(progress:get(), 0, 0.5, 0)
										end),
										30,
										1
									),
									Size = UDim2.new(0, 16, 0, 16),
								})

								return frame
							end,
							BarBase = function()
								return New("Frame")({
									BackgroundColor3 = Color3.new(1, 1, 1),
									Size = UDim2.new(1, 0, 1, 0),
									[Children] = {
										New("UICorner")({
											CornerRadius = UDim.new(1, 0),
										}),
										New("UIGradient")({
											Color = ColorSequence.new({
												ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
												ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 0, 255)),
												ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 0, 255)),
												ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
												ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 255, 0)),
												ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 255, 0)),
												ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
											}),
										}),
									},
								})
							end,
							BarFill = function()
								return {}
							end,
						},
					}),
				},
			}),
			New("Frame")({
				Name = "ButtonContainer",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 28),
				[Children] = {
					New("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
						Padding = UDim.new(0, 4),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					baseFrame({
						Appearance = {
							color = nil,
							transparency = 0,
							shadow = 2,
						},
						Stroke = useColor("Stroke", true),
						BackgroundColor3 = colorValue,
						Size = UDim2.new(0, 24, 0, 24),
					}),
					input({
						Color = "gray",
						Variant = "default",
						Placeholder = "#000000",
						Text = hexInputText,
						OnFocusLost = function(text, enterPressed)
							if enterPressed then
								local hex = text:match("(%x%x%x%x%x%x)")
								if hex then
									updateHandlesWithColor(Color3.fromHex(hex))
								else
									hexInputText:set("#" .. colorValue:get():ToHex():upper(), true)
								end
							end
						end,
						Size = UDim2.fromOffset(50, 24),
						[Children] = {
							New("UIFlexItem")({
								FlexMode = Enum.UIFlexMode.Fill,
							}),
						},
					}),
					New("Frame")({
						BackgroundTransparency = 1,
						Size = UDim2.new(0.4, 0, 0, 24),
						[Children] = {
							New("UISizeConstraint")({
								MinSize = Vector2.new(92, 0),
							}),
							New("UIListLayout")({
								FillDirection = Enum.FillDirection.Horizontal,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
								Padding = UDim.new(0, 4),
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),
							ForPairs({ R = rInputText, G = gInputText, B = bInputText }, function(index, value)
								return index,
									input({
										Name = index .. "Input",
										Color = "gray",
										Variant = "default",
										Placeholder = index,
										Text = value,
										TextAlignment = Enum.TextXAlignment.Center,
										OnFocusLost = function(text)
											if not tonumber(text) then
												value:set(tostring(math.floor(colorValue:get()[index] * 255)), true)
												return
											end

											local number = tonumber(text)

											if number < 0 then
												number = 0
											elseif number > 255 then
												number = 255
											end

											value:set(tostring(number), true)
											updateColorWithRGB()
										end,
										Size = UDim2.new(0.3, 0, 0, 24),
									})
							end, Clean),
						},
					}),
				},
			}),
		},
	})

	local component = New("Frame")({
		Name = "ColorPicker",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		[Children] = Computed(function()
			if props.HidePalette then
				return picker
			end

			return tabs({
				Color = tabsAppearance.Color,
				Variant = tabsAppearance.Variant,
				Tabs = {
					{
						Label = "Custom",
						Content = picker,
					},
					{
						Label = "Presets",
						Content = {
							New("Frame")({
								Name = "PaletteContainer",
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1,
								[Children] = {
									New("UIPadding")({
										PaddingTop = UDim.new(0, 4),
									}),
									New("UIListLayout")({
										FillDirection = Enum.FillDirection.Vertical,
										HorizontalAlignment = Enum.HorizontalAlignment.Center,
										Padding = UDim.new(0, 4),
										SortOrder = Enum.SortOrder.LayoutOrder,
										VerticalAlignment = Enum.VerticalAlignment.Top,
									}),
									baseFrame({
										Name = "PaletteButtons",
										Appearance = useColor("PaletteBackground", true),
										Padding = UDim.new(0, 2),
										Content = {
											New("ScrollingFrame")({
												AutomaticCanvasSize = Enum.AutomaticSize.Y,
												BackgroundTransparency = 1,
												BottomImage = "rbxassetid://0",
												CanvasSize = UDim2.new(0, 0, 0, 0),
												ScrollBarThickness = 1,
												Size = UDim2.new(1, 0, 1, 0),
												TopImage = "rbxassetid://0",
												[Children] = {
													New("UIGridLayout")({
														CellPadding = UDim2.new(0, 6, 0, 6),
														CellSize = UDim2.new(0, 30, 0, 30),
														FillDirection = Enum.FillDirection.Horizontal,
														HorizontalAlignment = Enum.HorizontalAlignment.Center,
														SortOrder = Enum.SortOrder.LayoutOrder,
														VerticalAlignment = Enum.VerticalAlignment.Top,
													}),
													New("UIPadding")({
														PaddingBottom = UDim.new(0, 2),
														PaddingLeft = UDim.new(0, 2),
														PaddingRight = UDim.new(0, 2),
														PaddingTop = UDim.new(0, 2),
													}),
													ForPairs(
														props.PaletteColors or brickColorMap,
														function(index, value)
															local isHovering = Value(false)
															local isPressing = Value(false)

															local usePaletteButtonColor = theme:get(
																"colorPickerPaletteButton",
																"gray",
																"default",
																Computed(function()
																	if isPressing:get() then
																		return "Press"
																	elseif isHovering:get() then
																		return "Hover"
																	end

																	return "Base"
																end)
															)

															return index,
																baseButton({
																	Name = "PaletteButton",
																	Appearance = usePaletteButtonColor(
																		"Background",
																		true
																	),
																	Stroke = usePaletteButtonColor("Stroke", true),
																	DisableHoverLighting = true,
																	LayoutOrder = index,
																	OnClick = function()
																		updateHandlesWithColor(value)

																		if props.OnColorChange then
																			props.OnColorChange(value)
																		end

																		if props.OnColorSet then
																			props.OnColorSet(value)
																		end
																	end,
																	OnHover = function(state)
																		isHovering:set(state)
																	end,
																	OnMouseButton1Changed = function(state)
																		isPressing:set(state)
																	end,
																	[Children] = {
																		baseFrame({
																			Appearance = {
																				color = value,
																				transparency = 0,
																			},
																			AnchorPoint = Vector2.new(0.5, 0.5),
																			Position = UDim2.new(0.5, 0, 0.5, 0),
																			Size = UDim2.new(1, -2, 1, -2),
																			ZIndex = -3,
																		}),
																	},
																})
														end,
														Clean
													),
												},
											}),
										},
										Size = UDim2.new(1, 0, 1, 0),
										[Children] = {
											New("UIFlexItem")({
												FlexMode = Enum.UIFlexMode.Fill,
											}),
										},
									}),
								},
							}) :: GuiObject,
						} :: { any },
					},
				},
				AppearanceOverride = tabsAppearance.AppearanceOverride,
			})
		end, Clean),
	})

	awaitLayer(component, function(layer)
		local function checkInputRange()
			local size = colorPickerSize:get()
			local mousePosition = layer.state.mousePosition:get()
			local distance = mousePosition - use(colorPickerPosition) - size / 2
			local horizontalDistance = math.abs(distance.X)
			local verticalDistance = math.abs(distance.Y)

			if horizontalDistance < size.X / 2 + 48 and verticalDistance < size.Y / 2 + 48 then
				return true
			end

			return false
		end

		local function updateMouse()
			local size = colorPickerSize:get()
			local mousePosition = layer.state.mousePosition:get()
			local distance = mousePosition - use(colorPickerPosition)

			local horizontalPercentage = math.clamp(distance.X / size.X, 0, 1)
			local verticalPercentage = math.clamp(distance.Y / size.Y, 0, 1)

			colorVector:set(Vector3.new(colorVector:get(false).X, horizontalPercentage, verticalPercentage))
		end

		inputCollector({
			ReferenceObject = use(colorPickerRef),
			Visible = Computed(function()
				local isDown, isHover = colorPickerDown:get(), colorPickerHover:get()

				if isHover then
					return true
				end

				if isDown then
					local isAllowedToDrag = checkInputRange()

					if not isAllowedToDrag then
						colorPickerDown:set(false)
					end

					return isAllowedToDrag
				end

				return false
			end),
			OnMouseButton1Changed = function(state)
				colorPickerDown:set(state)

				if state then
					updateMouse()

					if props.OnDragStart then
						props.OnDragStart(colorValue:get())
					end
				elseif lastSentColor:get() ~= colorValue:get() then
					lastSentColor:set(colorValue:get())

					if props.OnDragEnd then
						props.OnDragEnd(colorValue:get())
					end

					if props.OnColorSet then
						props.OnColorSet(colorValue:get())
					end
				end
			end,
		})

		table.insert(
			pendingCleanup,
			Observer(layer.state.mousePosition):onChange(function()
				if colorPickerDown:get() then
					-- get position of mouse relative to the color picker
					updateMouse()
				end
			end)
		)

		local function updateText()
			local color = colorValue:get()
			rInputText:set(tostring(math.round(color.R * 255)))
			gInputText:set(tostring(math.round(color.G * 255)))
			bInputText:set(tostring(math.round(color.B * 255)))
			hexInputText:set("#" .. color:ToHex():upper())
		end

		table.insert(pendingCleanup, Observer(colorValue):onChange(updateText))
		updateText()

		onDestroy(component, pendingCleanup)
	end)

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "Frame"))
end

return colorPicker
