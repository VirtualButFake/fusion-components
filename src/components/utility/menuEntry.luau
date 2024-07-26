local fusion = require("@packages/fusion")

local Children = fusion.Children
local Hydrate = fusion.Hydrate
local New = fusion.New

local Clean = fusion.cleanup
local Computed = fusion.Computed
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use
local propertyProvider = fusionUtils.propertyProvider
local getState = fusionUtils.getState

local theme = require("@src/theme")

local baseFrame = require("@components/base/frame")
local baseButton = require("@components/base/button")
local baseText = require("@components/base/text")
local baseIcon = require("@components/base/icon")

-- options were separated on purpose, so this is purely for appearance, while the actual options are in the props

type slots = {
	Left: ((useColor: theme.useColorFunction, option: option) -> fusion.CanBeState<{ any }>)?,
	Center: ((useColor: theme.useColorFunction, option: option) -> fusion.CanBeState<{ any }>)?,
	Right: ((useColor: theme.useColorFunction, option: option) -> fusion.CanBeState<{ any }>)?,
	Wrapper: ((useColor: theme.useColorFunction, option: option, component: Frame) -> fusion.CanBeState<{ any }>)?,
}

export type option = {
	Color: fusion.CanBeState<string>?,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Label: fusion.CanBeState<string> | baseText.text,
	LabelFullSize: boolean?,
	Icon: string? | baseIcon.icon?,
	Static: fusion.CanBeState<boolean>?,
	Disabled: fusion.CanBeState<boolean>?,
	Slots: slots?,
}

type props = {
	Option: option,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	FallbackColor: fusion.CanBeState<string>?,
	Pressing: fusion.CanBeState<boolean>?,
	Selected: fusion.CanBeState<boolean>?,
	Interactable: fusion.CanBeState<boolean>?,
	OnClick: (() -> any?)?,
	OnMouseButton1Changed: ((isPressed: boolean) -> any?)?,
	OnHover: ((isHovering: boolean) -> any)?,
	Slots: slots?,
	[any]: any,
}

local function menuEntry(props: props): Frame?
	-- this statement exists primarily when there's a dynamic option; this will make it refresh, but not render anything
	if props.Option == nil then
		return
	end

	local isHovering = Value(false)
	local isPressing = getState(props.Pressing or false)

	local useColor
	useColor = theme:get(
		"menuEntry",
		Computed(function()
			return use(props.Option.Color) or use(props.FallbackColor)
		end),
		"default",
		Computed(function()
			if use(props.Selected) and use(props.Option.Disabled) then
				return "SelectedDisabled"
			end

			if use(props.Option.Disabled) then
				return "Disabled"
			end

			if use(props.Option.Static) then
				return "Base"
			end

			if use(props.Selected) then
				return "Selected"
			end

			if use(props.Interactable) == false then
				return "Base"
			end

			if isPressing:get() then
				return "Pressing"
			end

			if isHovering:get() then
				return "Hover"
			end

			return "Base"
		end),
		props.AppearanceOverride or props.Option.AppearanceOverride
	)

	local slots = props.Option.Slots or {}

	if props.Slots then
		for key, value in props.Slots do
			slots[key] = value
		end
	end

	local component = baseButton({
		Name = "MenuEntry",
		Appearance = useColor("Background", true),
		Stroke = useColor("Stroke", true),
		Padding = UDim.new(0, 2),
		AutomaticSize = Enum.AutomaticSize.XY,
		Content = {
			New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			baseFrame({
				Name = "LabelIconContainer",
				Padding = {
					Top = UDim.new(0, 4),
					Bottom = UDim.new(0, 4),
					Left = UDim.new(0, 4),
					Right = UDim.new(0, 4),
				},
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				Content = {
					New("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 8),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					New("Frame")({
						Name = "LabelSlot",
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						LayoutOrder = 1,
						[Children] = {
							slots and slots.Center and slots.Center(useColor, props.Option) or baseText({
								Name = "Label",
								Appearance = useColor("Text", true),
								Text = props.Option.Label,
								AutomaticSize = props.Option.LabelFullSize and Enum.AutomaticSize.None
									or Enum.AutomaticSize.XY,
								BackgroundTransparency = 1,
								ClipsDescendants = true,
								Size = props.Option.LabelFullSize and UDim2.new(1, 0, 1, 0) or UDim2.new(),
								TextSize = Computed(function()
									if not use(props.Option.Label) or typeof(use(props.Option.Label)) == "string" then
										return 16
									end

									return use(props.Option.Label).TextSize
								end),
								TextXAlignment = Enum.TextXAlignment.Left,
							}),
						},
					}),
					New("Frame")({
						Name = "IconSlot",
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						[Children] = {
							slots and slots.Left and slots.Left(useColor, props.Option) or Computed(function()
								local iconData = use(props.Option.Icon)

								if iconData then
									return baseIcon({
										Icon = typeof(iconData) == "table" and iconData or {
											Name = iconData,
											Size = 16,
										},
										Color = useColor("Text", true),
										LayoutOrder = 0,
									})
								end

								return nil
							end, Clean),
						},
					}),
				},
			}),
			Computed(function()
				if slots and slots.Right then
					return New("Frame")({
						Name = "RightSlot",
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						[Children] = {
							New("UIFlexItem")({
								FlexMode = Enum.UIFlexMode.None,
							}),
							slots and slots.Right and slots.Right(useColor, props.Option),
						},
					})
				end

				return
			end, Clean),
		},
		DisableHoverLighting = Computed(function()
			return use(props.Option.Disabled) or use(props.Option.Static)
		end),
		Interactable = Computed(function()
			if use(props.Interactable) == false then
				return false
			end

			return true
		end),
		OnClick = props.OnClick and function()
			if use(props.Interactable) == false then
				return
			end

			if use(props.Option.Disabled) then
				return
			end

			return use(props.OnClick)()
		end,
		OnHover = function(state)
			isHovering:set(state)

			if use(props.OnHover) then
				use(props.OnHover)(state)
			end
		end,
		OnMouseButton1Changed = function(isPressed)
			if use(props.Interactable) == false then
				return
			end

			if use(props.Option.Static) then
				return
			end

			isPressing:set(isPressed)

			if use(props.OnMouseButton1Changed) then
				use(props.OnMouseButton1Changed)(isPressed)
			end
		end,
		Size = UDim2.new(0, 0, 0, 0),
	})

	if slots and slots.Wrapper then
		local wrapperComponent = use(slots.Wrapper)(useColor, props.Option, component)

		if wrapperComponent then
			if props.LayoutOrder then
				component.LayoutOrder = props.LayoutOrder
			end

			component = wrapperComponent
		end
	end

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "Frame"))
end

return menuEntry
