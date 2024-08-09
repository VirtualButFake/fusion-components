local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local fusion = require("@packages/fusion")
local Children = fusion.Children
local Hydrate = fusion.Hydrate
local New = fusion.New
local Change = fusion.OnChange
local Event = fusion.OnEvent
local Ref = fusion.Ref

local Cleanup = fusion.Cleanup
local Computed = fusion.Computed
local Observer = fusion.Observer
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local propertyProvider = fusionUtils.propertyProvider
local getState = fusionUtils.getState
local use = fusionUtils.use

local theme = require("@src/theme")

local baseButton = require("@components/base/button")
local baseTextbox = require("@components/base/textBox")
local baseIcon = require("@components/base/icon")

local plugin = script:FindFirstAncestorWhichIsA("Plugin")
local pluginMouse = plugin and plugin:GetMouse() or nil

type props = {
	Color: fusion.CanBeState<string>,
	Variant: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Disabled: fusion.CanBeState<boolean>?,
	Placeholder: fusion.CanBeState<string>?,
	Icon: string? | baseIcon.icon?,
	TrailingIcon: string? | baseIcon.icon?,
	Text: fusion.CanBeState<string>?,
	TextSize: fusion.CanBeState<number>?,
	TextXAlignment: fusion.CanBeState<Enum.TextXAlignment>?,
	TextYAlignment: fusion.CanBeState<Enum.TextYAlignment>?,
	BlockMouseIcon: fusion.CanBeState<boolean>?,
	OnTextChanged: ((text: string) -> nil)?,
	OnFocus: (() -> nil)?,
	OnFocusLost: ((text: string, enterPressed: boolean, input: InputObject) -> nil)?,
	Slots: {
		Left: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
		Right: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
	}?,
}

local function input(props: props): Frame
	local isFocused = Value(false)
	local isHovering = Value(false)

	local text = getState(props.Text or "")

	local component

	local shouldShowCursor = Computed(function()
		return use(isHovering) and not use(props.Disabled) and not use(props.BlockMouseIcon)
	end)

	local disconnect = Observer(shouldShowCursor):onChange(function()
		if pluginMouse then
			if use(shouldShowCursor) then
				local cursorImage = (CoreGui:IsAncestorOf(component) or StarterGui:IsAncestorOf(component))
						and "rbxasset://Textures/IBeamCursor.png"
					or "rbxasset://SystemCursors/IBeam"

				pluginMouse.Icon = cursorImage
			else
				pluginMouse.Icon = ""
			end
		end
	end)

	local useColor = theme:get(
		"input",
		props.Color,
		props.Variant,
		Computed(function()
			if use(props.Disabled) then
				return "Disabled"
			elseif use(isFocused) then
				return "Focus"
			elseif isHovering:get() then
				return "Hover"
			else
				return "Base"
			end
		end),
		props.AppearanceOverride
	)

	local textBox: fusion.Value<TextBox> = Value()

	component = baseButton({
		Name = "Input",
		Appearance = useColor("Background", true),
		Stroke = useColor("Stroke", true),
		Padding = {
			Left = UDim.new(0, 2),
			Right = UDim.new(0, 2),
		},
		Active = false,
		Content = {
			New("Frame")({
				Name = "ClippingContainer",
				BackgroundTransparency = 1,
				ClipsDescendants = true,

				Size = UDim2.fromScale(1, 1),
				[Children] = {
					New("UIPadding")({
						PaddingBottom = UDim.new(0, 2),
						PaddingLeft = UDim.new(0, 2),
						PaddingRight = UDim.new(0, 2),
						PaddingTop = UDim.new(0, 2),
					}),
					New("UIListLayout")({
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 4),
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					(props.Icon or (props.Slots and props.Slots.Left)) and New("Frame")({
						Name = "IconSlot",
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						LayoutOrder = 0,
						[Children] = {
							props.Slots and props.Slots.Left and props.Slots.Left(useColor)
								or props.Icon
									and baseIcon({
										Icon = props.Icon,
										Color = useColor("Text", true),
									}),
						},
					}),
					baseTextbox({
						Name = "InputBox",
						TextAppearance = useColor("Text", true),
						PlaceholderAppearance = useColor("Placeholder", true),
						BackgroundTransparency = 1,
						FontFace = use(theme.global.font),
						Interactable = Computed(function()
							return not use(props.Disabled)
						end),
						LayoutOrder = 1,
						PlaceholderText = props.Placeholder,
						Size = UDim2.fromScale(0, 1),
						Text = text,
						TextEditable = Computed(function()
							return not use(props.Disabled)
						end),
						TextSize = props.TextSize or 14,
						TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
						TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
						[Ref] = textBox,
						[Change("Text")] = function(newText)
							if props.OnTextChanged then
								props.OnTextChanged(newText)
							end
						end,
						[Children] = {
							New("UIFlexItem")({
								FlexMode = Enum.UIFlexMode.Fill,
							}),
						},
						[Event("Focused")] = function()
							isFocused:set(true)

							if props.OnFocus then
								props.OnFocus()
							end
						end,
						[Event("FocusLost")] = function(pressedEnter, inputObject)
							isFocused:set(false)

							if props.OnFocusLost then
								props.OnFocusLost(textBox:get().Text :: string, pressedEnter, inputObject)
							end
						end,
					}),
					(props.TrailingIcon or (props.Slots and props.Slots.Right)) and New("Frame")({
						Name = "TrailingIconSlot",
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						[Children] = {
							props.Slots and props.Slots.Right and props.Slots.Right(useColor)
								or props.TrailingIcon
									and baseIcon({
										Icon = props.TrailingIcon,
										Color = useColor("Text", true),
									}),
						},
					}),
				},
			}),
		},
		DisableHoverLighting = true,
		OnClick = function()
			if textBox:get(false) and not use(props.Disabled) then
				textBox:get(false):CaptureFocus()
			end
		end,
		OnHover = function(state)
			isHovering:set(state)
		end,
		[Cleanup] = {
			disconnect,
		},
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "Frame"))
end

return input
