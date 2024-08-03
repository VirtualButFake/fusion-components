local fusion = require("@packages/fusion")

local Children = fusion.Children
local Cleanup = fusion.Cleanup
local cleanup = fusion.Cleanup
local New = fusion.New
local Out = fusion.Out

local Clean = fusion.cleanup
local Computed = fusion.Computed
local ForPairs = fusion.ForPairs
local Observer = fusion.Observer
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use

local theme = require("@src/theme")

local baseFrame = require("@components/base/frame")
local baseIcon = require("@components/base/icon")

local menuEntry = require("@components/utility/menuEntry")
local popover = require("@components/utility/popover")

export type menu = {
	Visible: fusion.Value<boolean>,
	Parent: menu?,
}

export type option = fusion.CanBeState<
	menuEntry.option & {
		Callback: (() -> number?)?, -- the number determines how many parent context menus to close. -1 closes all, 0 closes none, 1 closes the parent, etc.
		Options: fusion.CanBeState<{ { option } }>?,
	}
>

type props = {
	Color: fusion.CanBeState<string>,
	Variant: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.colorTable>,
	Layer: fusionUtils.layer,
	State: {
		ParentPosition: fusion.Value<Vector2>,
		ParentSize: fusion.Value<Vector2>,
		MenuSize: fusion.Value<Vector2>,
		ResetPosition: fusion.Value<boolean>,
		Visible: fusion.Value<boolean>,
		ParentMenu: menu,
	},
	Position: {
		X: fusion.CanBeState<number>,
		Y: fusion.CanBeState<number>,
	},
	Options: fusion.CanBeState<{ { option } }>,
	CreateNewMenu: (any, any) -> any,
}

local function contextMenu(props: props): Frame
	local useColor = theme:get("popover", props.Color, props.Variant, "Base", props.AppearanceOverride)

	local mousePosition = props.Layer.state.mousePosition
	local targetSize = Value(Vector2.new(0, 0))

	local intermediateSize = Value(Vector2.new(0, 0))

	local function computeTargetPosition(mousePos: Vector3?)
		mousePos = mousePos or mousePosition:get()

		if not mousePos then
			return
		end

		local parentAbsPosition = props.State.ParentPosition:get() - props.Layer.referenceLayer.AbsolutePosition
		local parentAbsSize = props.State.ParentSize:get()
		local size = props.State.MenuSize:get()

		if size == nil then
			size = Vector2.new(0, 0)
		end

		if size.X < 4 or size.Y < 4 then
			-- this might seem weird at first, however; when size is 0, 0, the menu is positioned in the top left of the layer
			-- which causes a glitchy look. by positioning it off screen when in this state, the transition appears seamless
			return UDim2.new(2, 0, 2, 0)
		end

		local idealPosition = UDim2.new(
			0,
			mousePos.X - parentAbsPosition.X + size.X / 2 - props.Layer.referenceLayer.AbsolutePosition.X,
			0,
			mousePos.Y - parentAbsPosition.Y + size.Y / 2 - props.Layer.referenceLayer.AbsolutePosition.Y
		)

		if props.Position then
			idealPosition =
				UDim2.new(0, use(props.Position.X) or idealPosition.X, 0, use(props.Position.Y) or idealPosition.Y)
		end

		if size.X > parentAbsSize.X or size.Y > parentAbsSize.Y then
			parentAbsSize = Vector2.new(math.max(size.X, parentAbsSize.X), math.max(size.Y, parentAbsSize.Y))
		end

		local boundedPosition = UDim2.new(
			0,
			math.clamp(
				idealPosition.X.Offset,
				parentAbsPosition.X + size.X / 2,
				parentAbsPosition.X + parentAbsSize.X - size.X / 2
			),
			0,
			math.clamp(
				idealPosition.Y.Offset,
				parentAbsPosition.Y + size.Y / 2,
				parentAbsPosition.Y + parentAbsSize.Y - size.Y / 2
			)
		)

		return boundedPosition
	end

	local isVisible = Value(false)
	local lastPosition = Value(UDim2.new())
	local lastMousePosition = Value(Vector2.new())
	local lastLabelHover = Value(nil)

	local connections = {
		Observer(props.State.Visible):onChange(function()
			if props.State.Visible:get() then
				isVisible:set(true)
				return
			end

			task.delay(0.3, function()
				if not props.State.Visible:get() then
					isVisible:set(false)
				end
			end)
		end),
		Observer(intermediateSize):onChange(function()
			if intermediateSize:get() == nil then
				return
			end

			if props.State.Visible:get() and props.State.MenuSize then
				props.State.MenuSize:set(intermediateSize:get())
			end
		end),
	}

	local component
	component = popover({
		Name = "Menu",
		Variant = props.Variant,
		ParentComponent = props.Layer.referenceLayer,
		Position = Computed(function()
			if lastPosition:get() == nil then
				-- register dependencies
				computeTargetPosition()
			end

			if isVisible:get() and not props.State.ResetPosition:get() then
				return computeTargetPosition(lastMousePosition:get())
			else
				props.State.ResetPosition:set(false)
				lastMousePosition:set(mousePosition:get())

				local targetPosition = computeTargetPosition()
				lastPosition:set(targetPosition)
				return targetPosition
			end
		end),
		Content = {
			New("UIListLayout")({
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			ForPairs(props.Options, function(index: number, optionList: { option })
				return index,
					baseFrame({
						Name = "OptionSection",
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						[Children] = {
							baseFrame({
								Name = "Options",
								Padding = UDim.new(0, 2),
								AutomaticSize = Enum.AutomaticSize.XY,
								BackgroundTransparency = 1,
								Content = {
									ForPairs(optionList, function(optIndex: number, option: option)
										if use(option) == nil then
											return
										end

										local extendedState = {
											cleanup = {},
										}

										if use(option).Options then
											extendedState.isVisible = Value(false)
											extendedState.subMenuSize = Value(Vector2.new())
											table.insert(
												extendedState.cleanup,
												Observer(lastLabelHover):onChange(function()
													if lastLabelHover:get() ~= use(use(option).Label) then
														extendedState.isVisible:set(false)
													end
												end)
											)

											table.insert(
												extendedState.cleanup,
												Observer(props.State.Visible):onChange(function()
													if not props.State.Visible:get() then
														extendedState.isVisible:set(false)
													end
												end)
											)

											extendedState.entryPosition = Value(Vector2.new())

											local resetPosition = Value(false)

											local subMenuSize = Value(Vector2.new(0, 0))

											local positionX = Computed(function()
												local subSize = subMenuSize:get() or Vector2.new(0, 0)
												local size = props.State.MenuSize:get() or subSize
												local usedLastPosition = computeTargetPosition(lastMousePosition:get())

												return usedLastPosition.X.Offset + size.X / 2 + subSize.X / 2 + 4
											end)

											local positionY = Computed(function()
												local subSize = subMenuSize:get() or Vector2.new(0, 0)

												if extendedState.entryPosition:get() == nil then
													return 0
												end

												local relativePosition = extendedState.entryPosition:get()
													- props.Layer.referenceLayer.AbsolutePosition

												return relativePosition.Y + subSize.Y / 2
											end)

											table.insert(
												extendedState.cleanup,
												Observer(positionX):onChange(function()
													resetPosition:set(true)
												end)
											)

											table.insert(
												extendedState.cleanup,
												Observer(positionY):onChange(function()
													resetPosition:set(true)
												end)
											)

											props.CreateNewMenu(props.Layer.referenceLayer, {
												Color = props.Color,
												Variant = props.Variant,
												Options = use(use(option).Options),
												Visible = extendedState.isVisible,
												ParentMenu = {
													Visible = extendedState.isVisible,
													Parent = props.State.ParentMenu,
												},
												StateOutput = {
													Size = subMenuSize,
													ResetPosition = resetPosition,
												},
												EnabledLogic = function()
													return false
												end,
												Position = {
													X = positionX,
													Y = positionY,
												},
											})

											table.insert(extendedState.cleanup, function()
												extendedState.isVisible:set(false)
											end)
										end

										return optIndex,
											menuEntry({
												Option = use(option),
												FallbackColor = props.Color,
												OnClick = function()
													if not isVisible:get() or not props.State.Visible:get() then
														return
													end

													if use(use(option).Callback) then
														local closeAmount = use(use(option).Callback)()

														if closeAmount then
															local currentParent

															if closeAmount > 0 then
																currentParent = props.State.ParentMenu

																for _ = 2, closeAmount do
																	if
																		currentParent
																		and currentParent.Menu
																		and currentParent.Menu.Parent
																	then
																		currentParent = currentParent.Menu.Parent
																	end
																end
															elseif closeAmount == -1 then
																currentParent = props.State.ParentMenu

																while
																	currentParent
																	and currentParent.Menu
																	and currentParent.Menu.Parent
																do
																	currentParent = currentParent.Menu.Parent
																end
															end

															if currentParent then
																currentParent.Visible:set(false)
															end
														end
													end
												end,
												OnHover = function(hovering)
													if hovering then
														-- get all menus in our layer
														local content = props.Layer.contents:get(false)

														local mousePos = props.Layer.state.mousePosition:get(false)
														local mouseVector2 = Vector2.new(mousePos.X, mousePos.Y)

														local menuOrder = {}

														for _, object in content do
															if object.Name == "Menu" then
																if object ~= component then
																	local objectPosition = object.AbsolutePosition
																	local objectSize = object.AbsoluteSize

																	-- see if our mouse position is within the bounds of the menu
																	if
																		mouseVector2.X >= objectPosition.X
																		and mouseVector2.X <= objectPosition.X + objectSize.X
																		and mouseVector2.Y >= objectPosition.Y
																		and mouseVector2.Y
																			<= objectPosition.Y + objectSize.Y
																	then
																		table.insert(menuOrder, object)
																	end
																else
																	table.insert(menuOrder, object)
																end
															end
														end

														if table.find(menuOrder, component) ~= #menuOrder then
															return
														end

														lastLabelHover:set(use(option).Label)

														if
															extendedState.isVisible
															and props.State.Visible:get()
															and not use(use(option).Disabled)
														then
															extendedState.isVisible:set(true)
														end
													end
												end,
												Slots = use(use(option).Options) and {
													Right = function(useSlotColor)
														return Computed(function()
															return New("Frame")({
																Name = "SubMenuArrow",
																AutomaticSize = Enum.AutomaticSize.XY,
																BackgroundTransparency = 1,
																[Children] = {
																	baseIcon({
																		Icon = {
																			Name = "chevron-right",
																			Size = 16,
																		},
																		Color = useSlotColor("Text", true),
																	}),
																},
															})
														end, Clean)
													end,
												} or nil,
												LayoutOrder = optIndex,
												[cleanup] = extendedState.cleanup,
												[Out("AbsolutePosition")] = extendedState.entryPosition,
											})
									end, Clean),
									New("UIListLayout")({
										FillDirection = Enum.FillDirection.Vertical,
										HorizontalAlignment = Enum.HorizontalAlignment.Center,
										HorizontalFlex = Enum.UIFlexAlignment.Fill,
										Padding = UDim.new(0, 2),
										SortOrder = Enum.SortOrder.LayoutOrder,
										VerticalAlignment = Enum.VerticalAlignment.Center,
									}),
								},
							}),
							New("UIListLayout")({
								FillDirection = Enum.FillDirection.Vertical,
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								HorizontalFlex = Enum.UIFlexAlignment.Fill,
								Padding = UDim.new(0, 0),
								SortOrder = Enum.SortOrder.LayoutOrder,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							}),
							Computed(function()
								if index < #use(props.Options) then
									return baseFrame({
										Name = "Divider",
										Appearance = useColor("Stroke", true),
										LayoutOrder = index,
										Size = UDim2.new(0, 0, 0, 1),
									})
								end

								return
							end, Clean),
						},
					})
			end, Clean),
		},
		AnchorPoint = Vector2.new(0.5, 0.5),
		Appearance = useColor("Background", true),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		CornerRadius = 2,
		Padding = UDim.new(0, 0),
		PopoverSize = intermediateSize,
		Stroke = useColor("Stroke", true),
		Visible = props.State.Visible,
		[Cleanup] = {
			connections,
			Observer(targetSize):onChange(function()
				if targetSize:get() == nil then
					return
				end

				props.State.MenuSize:set(targetSize:get())
			end),
		},
	})

	return component
end

return contextMenu
