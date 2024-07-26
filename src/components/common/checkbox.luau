local fusion = require("@packages/fusion")
local Tween = fusion.Tween

local Hydrate = fusion.Hydrate

local Computed = fusion.Computed
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local propertyProvider = fusionUtils.propertyProvider
local use = fusionUtils.use
local getState = fusionUtils.getState

local theme = require("@src/theme")

local baseIcon = require("@components/base/icon")
local baseButton = require("@components/base/button")

type props = {
	Color: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Disabled: fusion.CanBeState<boolean>?,
	State: fusion.CanBeState<boolean>?,
	Icon: string? | baseIcon.icon?,
	Padding: number?,
	OnClick: ((state: fusion.StateObject<boolean>) -> nil)?,
}

local function checkbox(props: props): TextButton
	local isHovering = Value(false)
	local checkboxState = getState(props.State or false)

	local currentVisualState = Computed(function()
		if use(props.Disabled) then
			if checkboxState:get() then
				return "DisabledActive"
			end

			return "Disabled"
		elseif isHovering:get() then
			if checkboxState:get() then
				return "HoverActive"
			end

			return "Hover"
		elseif checkboxState:get() then
			return "Active"
		else
			return "Base"
		end
	end)

	local useColor = theme:get("checkbox", props.Color, "default", currentVisualState, props.AppearanceOverride)

	local component = baseButton({
		Name = "CheckboxContainer",
		Appearance = useColor("Background", true),
		Stroke = useColor("Stroke", true),
		Padding = UDim.new(0, props.Padding or 4),
		Content = {
			baseIcon({
				Name = "CheckboxIcon",
				Icon = props.Icon and typeof(props.Icon) == "table" and props.Icon
					or typeof(props.Icon) == "string" and {
						Name = props.Icon,
						Size = 16,
					}
					or {
						Name = "check",
						Size = 16,
					},
				Color = useColor("Text", true),
				ImageTransparency = Tween(
					Computed(function()
						return checkboxState:get() and 0 or 1
					end),
					TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
				),
			}),
		},
		DisableHoverLighting = props.Disabled,
		OnClick = function()
			if use(props.Disabled) then
				return
			end

			if props.OnClick then
				props.OnClick(checkboxState)
			else
				checkboxState:set(not checkboxState:get())
			end
		end,
		OnHover = function(state)
			isHovering:set(state)
		end,
		Size = UDim2.new(0, 24, 0, 24),
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "TextButton")) :: TextButton
end

return checkbox
