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

type props = {
	Appearance: fusion.CanBeState<theme.color>,
	Image: fusion.CanBeState<string>,
	TweenSettings: TweenInfo?,
	[any]: any,
}

local function imageLabel(props: props)
	if props.TweenSettings == nil then
		props.TweenSettings = TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	end

	local imageColor3 = props.ImageColor3
		or peek(props.Appearance) ~= nil and Tween(
			Computed(function()
				return use(props.Appearance).color
			end),
			props.TweenSettings
		)
		or Color3.fromRGB(255, 255, 255)

	local imageTransparency = props.ImageTransparency
		or peek(props.Appearance) ~= nil and Tween(
			Computed(function()
				return use(props.Appearance).transparency
			end),
			props.TweenSettings
		)
		or 0

	local component = New("ImageLabel")({
		BackgroundTransparency = 1,
		Image = props.Image,
		ImageColor3 = typeof(imageColor3) == "table" and Tween(imageColor3, props.TweenSettings) or imageColor3,
		ImageTransparency = typeof(imageTransparency) == "table" and Tween(imageTransparency, props.TweenSettings)
			or imageTransparency,
	})

	local properties = propertyProvider.getPropsAndSpecialKeys(props, "ImageLabel")
	return Hydrate(component)(properties)
end

return imageLabel
