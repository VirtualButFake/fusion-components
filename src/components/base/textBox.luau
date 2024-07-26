local fusion = require("@packages/fusion")
local Tween = fusion.Tween

local Hydrate = fusion.Hydrate
local New = fusion.New

local Computed = fusion.Computed

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use
local propertyProvider = fusionUtils.propertyProvider

local theme = require("@src/theme")

type props = {
	TextAppearance: fusion.CanBeState<theme.color>,
	PlaceholderAppearance: fusion.CanBeState<theme.color>,
	TweenSettings: TweenInfo?,
	[any]: any,
}

local function textBox(props: props)
	if props.TweenSettings == nil then
		props.TweenSettings = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	end

	local component = New("TextBox")({
		BackgroundTransparency = 1,
		PlaceholderColor3 = Tween(
			Computed(function()
				return use(props.PlaceholderAppearance).color
			end),
			props.TweenSettings
		),
		Text = props.Text,
		TextColor3 = Tween(
			Computed(function()
				return use(props.TextAppearance).color
			end),
			props.TweenSettings
		),
		TextTransparency = Tween(
			Computed(function()
				return use(props.TextAppearance).transparency
			end),
			props.TweenSettings
		),
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "TextBox"))
end

return textBox
