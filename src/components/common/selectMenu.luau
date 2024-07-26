local fusion = require("@packages/fusion")
local Children = fusion.Children
local Cleanup = fusion.Cleanup
local Hydrate = fusion.Hydrate
local New = fusion.New
local Out = fusion.Out

local Clean = fusion.cleanup
local Computed = fusion.Computed
local ForPairs = fusion.ForPairs
local Observer = fusion.Observer
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local propertyProvider = fusionUtils.propertyProvider
local use = fusionUtils.use
local getState = fusionUtils.getState
local awaitLayer = fusionUtils.awaitLayer

local theme = require("@src/theme")

local baseIcon = require("@components/base/icon")
local baseButton = require("@components/base/button")
local baseText = require("@components/base/text")
local baseFrame = require("@components/base/frame")

local input = require("@components/common/input")
local popover = require("@components/common/popover")
local placementPopover = require("@components/utility/placementPopover")
local menuEntry = require("@components/utility/menuEntry")
local scrollingFrame = require("@components/common/scrollingFrame")

type option = {
	Id: string,
	Label: string?,
	Icon: string? | baseIcon.icon?,
	Slots: {
		Left: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
		Center: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
	}?,
}

type props = {
	Color: fusion.CanBeState<string>,
	Variant: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	PopoverAppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	EntryAppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Disabled: fusion.CanBeState<boolean>?,
	Visible: fusion.CanBeState<boolean>?,
	MaxHeight: number?,
	ToggleIcon: string? | baseIcon.icon?,
	SelectedIcon: string? | baseIcon.icon?,
	SearchQuery: fusion.CanBeState<string>?,
	Search: ((query: string, options: { option }) -> { option })?,
	Searchable: fusion.CanBeState<boolean>?,
	SearchPlaceholder: fusion.CanBeState<string>?,
	Placement: placementPopover.placement?,
	Options: fusion.CanBeState<{ option }>,
	SelectedOptions: fusion.CanBeState<{ string }>?,
	Placeholder: fusion.CanBeState<string>?,
	Multiple: fusion.CanBeState<boolean>?,
	Creatable: fusion.CanBeState<boolean>?,
	CreatableWhen: ("empty" | "always" | ((query: string) -> boolean))?,
	OnCreate: ((query: string) -> nil)?,
	OnOptionClicked: (id: string, isVisible: fusion.Value<boolean>) -> nil,
	Slots: {
		LeftInput: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
		Label: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
		RightInput: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
		CreateOption: ((useColor: theme.useColorFunction, query: string) -> fusion.CanBeState<{ any }>)?,
	}?,
}

local function selectMenu(props: props): Frame
	local isVisible = getState(props.Visible or false)
	local isHovering = Value(false)

	local isSelfParentedToGame = Value(false)

	local searchQuery = getState(props.SearchQuery or "")
	local selectedOptions = getState(props.SelectedOptions and use(props.SelectedOptions) or {})

	local useColor = theme:get(
		"input",
		props.Color,
		props.Variant,
		Computed(function()
			if use(props.Disabled) then
				return "Disabled"
			elseif use(isVisible) then
				return "Focus"
			elseif isHovering:get() then
				return "Hover"
			else
				return "Base"
			end
		end),
		props.AppearanceOverride
	)

	local componentSize = Value(nil)
	local shownResults = Computed(function()
		local foundResults = {}

		if not use(searchQuery) or use(searchQuery) == "" or not use(props.Searchable) then
			foundResults = use(props.Options)
		elseif props.Search then
			foundResults = props.Search(searchQuery, use(props.Options))
		else
			for _, option in use(props.Options) do
				local identifier = option.Label or option.Id

				if string.find(string.lower(identifier), string.lower(use(searchQuery))) then
					table.insert(foundResults, option)
				end
			end
		end

		return foundResults
	end)

	local pendingCleanup = {}

	if typeof(props.SelectedOptions) == "table" and (props.SelectedOptions :: any).get then
		table.insert(
			pendingCleanup,
			Observer(props.SelectedOptions):onChange(function()
				-- see if there's a difference between the current selected options and the new selected options
				local newSelectedOptions = (props.SelectedOptions :: any):get()
				local currentSelectedOptions = selectedOptions:get()

				local hasDifference = false

				if #newSelectedOptions ~= #currentSelectedOptions then
					hasDifference = true
				else
					for _, option in ipairs(newSelectedOptions) do
						if not table.find(currentSelectedOptions, option) then
							hasDifference = true
							break
						end
					end
				end

				if hasDifference then
					selectedOptions:set((props.SelectedOptions :: any):get())
				end
			end)
		)
	end

	local component = baseButton({
		Name = "Input",
		Appearance = useColor("Background", true),
		Stroke = useColor("Stroke", true),
		AppearanceOverride = props.AppearanceOverride,
		Padding = {
			Right = UDim.new(0, 4),
			Left = UDim.new(0, 4),
		},
		Active = false,
		Content = {
			New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			New("Frame")({
				Name = "IconSlot",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = 0,
				Visible = Computed(function()
					if use(props.Multiple) then
						return false
					end

					local selectedOption = use(selectedOptions)[1]

					if selectedOption then
						for _, option in use(props.Options) do
							if option.Id == selectedOption then
								return option.Icon ~= nil
							end
						end
					end

					return false
				end),
				[Children] = {
					props.Slots and props.Slots.LeftInput and props.Slots.LeftInput(useColor) or Computed(function()
						if not props.Multiple then
							-- get the currently selected value
							local selectedOption = use(selectedOptions)[1]

							if selectedOption then
								for _, option in use(props.Options) do
									if option.Id == selectedOption then
										return option.Icon
												and baseIcon({
													Icon = option.Icon,
													Color = useColor("Text", true),
												})
											or nil
									end
								end
							end
						end

						return nil
					end, Clean),
				},
			}),
			props.Slots and props.Slots.Label and props.Slots.Label(useColor) or baseText({
				Appearance = Computed(function()
					if #use(selectedOptions) == 0 then
						return useColor("Placeholder")
					end

					return useColor("Text")
				end),
				Text = Computed(function()
					if #use(selectedOptions) == 0 then
						return use(props.Placeholder) or "Select option"
					end

					local selectedOptionList = {}

					for _, option in use(props.Options) do
						if table.find(use(selectedOptions), option.Id) then
							table.insert(selectedOptionList, option.Label or option.Id)
						end
					end

					return table.concat(selectedOptionList, ", ") or ""
				end),
				AutomaticSize = Enum.AutomaticSize.X,
				ClipsDescendants = true,
				Size = UDim2.new(0, 0, 1, 0),
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,
				[Children] = {
					New("UIFlexItem")({
						FlexMode = Enum.UIFlexMode.Fill,
					}),
					New("UIPadding")({
						PaddingLeft = UDim.new(0, 2),
					}),
				},
			}),
			New("Frame")({
				Name = "TrailingIconSlot",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				[Children] = {
					props.Slots and props.Slots.RightInput and props.Slots.RightInput(useColor) or baseIcon({
						Icon = props.ToggleIcon or {
							Name = "chevron-down",
							Size = 16,
						},
					}),
				},
			}),
		},
		DisableHoverLighting = true,
		OnClick = function()
			isVisible:set(not isVisible:get())
		end,
		OnHover = function(state)
			isHovering:set(state)
		end,
		[Out("AbsoluteSize")] = componentSize,
		[Cleanup] = pendingCleanup,
	})

	table.insert(
		pendingCleanup,
		component.AncestryChanged:Connect(function()
			isSelfParentedToGame:set(game:IsAncestorOf(component))
		end)
	)

	awaitLayer(component, function(layer)
		local isYScrollable = Value()

		popover(component, {
			Variant = "default",
			AppearanceOverride = props.PopoverAppearanceOverride,
			Placement = props.Placement or "bottom",
			Visible = Computed(function()
				return use(isVisible) and not use(props.Disabled) and isSelfParentedToGame:get()
			end),
			Padding = UDim.new(0, 0),
			Content = function(usePopoverColor)
				return {
					New("UIListLayout")({
						FillDirection = Enum.FillDirection.Vertical,
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					}),
					New("UISizeConstraint")({
						MaxSize = Computed(function()
							if use(componentSize) == nil then
								return Vector2.new(0, 0)
							end

							return Vector2.new(math.clamp(use(componentSize).X, 1, math.huge), math.huge)
						end),
					}),
					Computed(function()
						if use(props.Searchable) then
							return baseFrame({
								Name = "SearchFrame",
								AutomaticSize = Enum.AutomaticSize.Y,
								BackgroundTransparency = 1,
								Size = UDim2.new(1, 0, 0, 0),
								Padding = {
									Left = UDim.new(0, 4),
									Right = UDim.new(0, 4),
									Top = UDim.new(0, 4),
								},
								[Children] = {
									New("UIListLayout")({
										FillDirection = Enum.FillDirection.Vertical,
										Padding = UDim.new(0, 4),
										SortOrder = Enum.SortOrder.LayoutOrder,
										HorizontalAlignment = Enum.HorizontalAlignment.Center,
									}),
									input({
										Color = props.Color,
										Variant = "transparent",
										Text = searchQuery,
										Placeholder = props.SearchPlaceholder or "Search",
										Size = UDim2.new(1, 0, 0, 20),
										LayoutOrder = -1,
										OnTextChanged = function(text)
											searchQuery:set(text)
										end,
									}),
									New("Frame")({
										BackgroundColor3 = Computed(function()
											return usePopoverColor("Stroke").color
										end),
										Size = UDim2.new(1, 8, 0, 1),
									}),
								},
							})
						end

						return
					end, Clean),
					scrollingFrame({
						BackgroundTransparency = 1,
						IsYBarVisible = isYScrollable,
						ScrollingFrameProps = {
							AutomaticCanvasSize = Enum.AutomaticSize.Y,
							CanvasSize = UDim2.new(0, 0, 0, 0),
							VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
						},
						Size = Computed(function()
							if use(componentSize) == nil then
								return UDim2.new(0, 0, 0, 0)
							end

							local renderedAmount = math.min(#use(shownResults), props.MaxHeight or 5)

							if renderedAmount == 0 then
								renderedAmount = 1
							end

							return UDim2.new(0, use(componentSize).X, 0, 28 * renderedAmount + (2 * renderedAmount) + 2)
						end),
						[Children] = {
							New("UIPadding")({
								PaddingTop = UDim.new(0, 2),
								PaddingBottom = UDim.new(0, 2),
								PaddingRight = UDim.new(0, 2),
							}),
						},
						Content = {
							New("UIPadding")({
								PaddingLeft = UDim.new(0, 2),
								PaddingRight = Computed(function()
									if isYScrollable:get() then
										return UDim.new(0, 4)
									end

									return UDim.new(0, 0)
								end),
							}),
							New("UIListLayout")({
								HorizontalFlex = Enum.UIFlexAlignment.Fill,
								Padding = UDim.new(0, 2),
								SortOrder = Enum.SortOrder.LayoutOrder,
							}),
							Computed(function()
								if use(props.Creatable) then
									local creatableWhen = use(props.CreatableWhen) or "empty"

									if
										creatableWhen == "always"
										or (creatableWhen == "empty" and #use(shownResults) == 0)
										or (typeof(creatableWhen) == "function" and creatableWhen(use(searchQuery)))
									then
										return props.Slots
												and props.Slots.CreateOption
												and props.Slots.CreateOption(usePopoverColor, searchQuery)
											or menuEntry({
												Option = {
													Color = "gray",
													Label = 'Create "' .. use(searchQuery) .. '"',
												},
												OnClick = function()
													if props.OnCreate then
														props.OnCreate(use(searchQuery))
													end
												end,
											})
									end
								end

								if #use(shownResults) == 0 then
									return menuEntry({
										Option = {
											Disabled = true,
											Label = "No results",
											Color = "gray",
										},
									})
								end

								return
							end, Clean),
							ForPairs(shownResults, function(index, option)
								local optionProperties = {
									Label = option.Label or option.Id,
									Icon = option.Icon,
									LabelFullSize = true,
									Slots = {
										Left = option.Slots and option.Slots.Left,
										Center = option.Slots and option.Slots.Center,
										Right = function(useSlotColor)
											return Computed(function()
												if table.find(use(selectedOptions), option.Id) then
													return baseIcon({
														Icon = props.SelectedIcon or "check",
														Color = useSlotColor("Text", true),
													})
												end

												return
											end, Clean)
										end,
									},
								}

								for idx, value in option do
									if idx == "Slots" then
										for slotIdx, slotValue in value do
											optionProperties.Slots[slotIdx] = slotValue
										end

										continue
									end

									optionProperties[idx] = value
								end

								local selectEntry = menuEntry({
									Option = optionProperties,
									FallbackColor = "gray",
									Selected = Computed(function()
										return table.find(use(selectedOptions), option.Id)
									end),
									Interactable = Computed(function()
										return use(isVisible) and not use(props.Disabled)
									end),
									OnMouseButton1Changed = function(state)
										if not state then
											return
										end

										if props.OnOptionClicked then
											props.OnOptionClicked(option.Id, isVisible)
										end
									end,
									AppearanceOverride = props.EntryAppearanceOverride,
									Size = UDim2.new(1, 0, 0, 0),
								})

								return index, selectEntry
							end, Clean),
						},
					}),
				}
			end,
			ParentComponent = layer.referenceLayer,
			PositionAnimation = true,
		})
	end)

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "Frame"))
end

return selectMenu
