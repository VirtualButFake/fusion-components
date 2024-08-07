local fusion = require("@packages/fusion")
local Tween = fusion.Tween

local Hydrate = fusion.Hydrate
local New = fusion.New

local Computed = fusion.Computed

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use
local peek = fusionUtils.peek
local propertyProvider = fusionUtils.propertyProvider

local theme = require("@src/theme")

export type text = {
	Label: fusion.CanBeState<string>,
	Font: fusion.CanBeState<Font>,
	TextSize: fusion.CanBeState<number>,
}

type props = {
	Appearance: fusion.CanBeState<theme.color>,
	Text: fusion.CanBeState<string> | text,
	TweenSettings: TweenInfo?,
	[any]: any,
}

local function text(props: props)
	if props.TweenSettings == nil then
		props.TweenSettings = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	end

	local convertedText = type(props.Text) == "table" and peek(props.Text) == props.Text and props.Text :: text
		or {
			Label = Computed(function()
				return use(props.Text)
			end),
			Font = use(theme.global.font),
			TextSize = 14,
		} :: text

	local component = New("TextLabel")({
		BackgroundTransparency = 1,
		FontFace = convertedText.Font,
		Text = convertedText.Label,
		TextColor3 = Tween(
			Computed(function()
				return use(props.Appearance).color
			end),
			props.TweenSettings
		),
		TextSize = convertedText.TextSize,
		TextTransparency = Tween(
			Computed(function()
				return use(props.Appearance).transparency
			end),
			props.TweenSettings
		),
	})

	local clonedProps: { [any]: any } = table.clone(props)
	clonedProps.Text = nil

	local properties = propertyProvider.getPropsAndSpecialKeys(clonedProps, "TextLabel")
	return Hydrate(component)(properties)
end

return text
