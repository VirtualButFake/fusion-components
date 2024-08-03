local fusion = require("@packages/fusion")

local Children = fusion.Children
local Hydrate = fusion.Hydrate
local New = fusion.New
local Out = fusion.Out
local Cleanup = fusion.Cleanup

local Clean = fusion.cleanup
local Computed = fusion.Computed
local ForPairs = fusion.ForPairs
local Observer = fusion.Observer
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local getState = fusionUtils.getState
local awaitLayer = fusionUtils.awaitLayer
local use = fusionUtils.use
local propertyProvider = fusionUtils.propertyProvider

local theme = require("@src/theme")

local baseButton = require("@components/base/button")
local baseIcon = require("@components/base/icon")

local menuEntry = require("@components/utility/menuEntry")
local placementPopover = require("@components/utility/placementPopover")
local popover = require("@components/common/popover")
local input = require("@components/common/input")
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
	Color: fusion.CanBeState<string>?,
	Variant: fusion.CanBeState<string>?,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	PopoverAppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	EntryAppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Disabled: fusion.CanBeState<boolean>?,
	Visible: fusion.CanBeState<boolean>?,
	MaxHeight: number?,
	ToggleIcon: string? | baseIcon.icon?,
	SelectedIcon: string? | baseIcon.icon?,
	Search: ((query: string, options: { option }) -> { option })?, -- by default, searches on id
	Placeholder: fusion.CanBeState<string>?,
	Query: fusion.CanBeState<string>?,
	SelectedOption: fusion.CanBeState<string>?,
	Placement: placementPopover.placement?,
	Options: fusion.CanBeState<{ option }>,
	OnOptionSelected: ((id: string) -> nil)?,
	Slots: {
		Left: ((useColor: theme.useColorFunction, option: fusion.Computed<option>?) -> fusion.CanBeState<{ any }>)?,
	}?,
}

local function inputMenu(props: props): Frame
	local isVisible = getState(props.Visible or false)
	local blockMouseIcon = Value(false)

	local query = getState(props.Query)
	local selectedOption = getState(props.SelectedOption and use(props.SelectedOption) or nil)

	local shownResults = Computed(function()
		local foundResults = {}

		if not use(query) or use(query) == "" then
			foundResults = props.Options
		elseif props.Search then
			foundResults = props.Search(query, props.Options)
		else
			for _, option in use(props.Options) do
				local identifier = option.Label or option.Id

				if string.find(string.lower(identifier), string.lower(use(query))) then
					table.insert(foundResults, option)
				end
			end
		end

		return foundResults
	end)

	local componentSize: Vector2 = Value()
	local isMenuBeingHovered = Value(false)

	local function setOption(option: option)
		query:set(option.Label or option.Id)

		if props.OnOptionSelected then
			props.OnOptionSelected(option.Id)
		end

		selectedOption:set(option.Id)
	end

	local component = input({
		Color = props.Color,
		Variant = props.Variant,
		AppearanceOverride = props.AppearanceOverride,
		Disabled = props.Disabled,
		Placeholder = props.Placeholder,
		Text = query,
		BlockMouseIcon = blockMouseIcon,
		OnTextChanged = function(text)
			query:set(text)
		end,
		OnFocus = function()
			isVisible:set(true)
		end,
		OnFocusLost = function(_, pressedEnter)
			if not isMenuBeingHovered:get() or pressedEnter then
				task.delay(0.1, function()
					isVisible:set(false)
				end)
			end

			if pressedEnter then
				if #use(shownResults) == 1 then
					local option = use(shownResults)[1]
					setOption(option)
				end
			end
		end,
		Slots = {
			Left = props.Slots and props.Slots.Left and function(useColor)
				return props.Slots.Left(
					useColor,
					Computed(function()
						local option

						for _, opt in (use(shownResults)) do
							if opt.Id == selectedOption:get() then
								option = opt
								break
							end
						end

						return option
					end, Clean)
				)
			end or function(useColor)
				return Computed(function()
					if selectedOption:get() then
						local option

						for _, opt in (use(shownResults)) do
							if opt.Id == selectedOption:get() then
								option = opt
								break
							end
						end

						if option and option.Icon then
							return baseIcon({
								Icon = option.Icon,
								Color = useColor("Text", true),
							})
						end
					end

					return
				end, Clean)
			end,
			Right = function(useColor)
				return baseButton({
					Appearance = {
						color = Color3.fromRGB(255, 255, 255),
						transparency = 1,
					},
					Content = {
						baseIcon({
							Name = "ToggleIcon",
							Icon = {
								Name = props.ToggleIcon or "chevron-down",
								Size = 16,
							},
							Color = useColor("Text", true),
						}),
					},
					AutomaticSize = Enum.AutomaticSize.XY,
					OnClick = function()
						if use(props.Disabled) then
							return
						end

						isVisible:set(not isVisible:get())
					end,
					OnHover = function(isHovering)
						blockMouseIcon:set(isHovering)
					end,
				})
			end,
		},
		[Out("AbsoluteSize")] = componentSize,
		[Cleanup] = {
			typeof(props.SelectedOption) == "table"
					and props.SelectedOption.get
					and Observer(props.SelectedOption):onChange(function()
						if selectedOption:get() == props.SelectedOption:get() then
							return
						end

						selectedOption:set(props.SelectedOption:get())
					end)
				or nil,
		},
	})

	awaitLayer(component, function()
		local isYScrollable = Value()

		popover(component, {
			Placement = props.Placement or "bottom",
			PositionAnimation = true,
			Variant = "default",
			AppearanceOverride = props.PopoverAppearanceOverride,
			Visible = fusion.Computed(function()
				return use(isVisible) and not use(props.Disabled)
			end),
			Content = {
				New("UISizeConstraint")({
					MaxSize = Computed(function()
						if use(componentSize) == nil then
							return Vector2.new(0, 0)
						end

						return Vector2.new(use(componentSize).X, math.huge)
					end),
				}),
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

						return UDim2.new(0, use(componentSize).X - 4, 0, 28 * renderedAmount + (2 * renderedAmount) + 2)
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
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, 2),
							HorizontalFlex = Enum.UIFlexAlignment.Fill,
						}),
						Computed(function()
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
							option.Slots = option.Slots or {}
							option.Slots.Right = function(useColor)
								return Computed(function()
									if option.Id == use(selectedOption) then
										return baseIcon({
											Icon = props.SelectedIcon or "check",
											Color = useColor("Text", true),
										})
									end

									return
								end, Clean)
							end

							local inputEntry = menuEntry({
								AppearanceOverride = props.EntryAppearanceOverride,
								Option = {
									Label = option.Label or option.Id,
									Icon = option.Icon,
									LabelFullSize = true,
									Slots = option.Slots,
								},
								Selected = Computed(function()
									return option.Id == use(selectedOption)
								end),
								Interactable = Computed(function()
									return use(isVisible) and not use(props.Disabled)
								end),
								Size = UDim2.new(1, 0, 0, 0),
								FallbackColor = "gray",
								OnMouseButton1Changed = function(state)
									if not state then
										return
									end

									isVisible:set(false)
									setOption(option)
								end,
							})

							return index, inputEntry
						end, Clean),
					},
				}),
			},
		})
	end)

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "Frame"))
end

return inputMenu
