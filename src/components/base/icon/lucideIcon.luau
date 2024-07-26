local fusion = require("@packages/fusion")
local Hydrate = fusion.Hydrate
local Computed = fusion.Computed

local lucide = require("@packages/Lucide")

local fusionUtils = require("@packages/fusionUtils")
local propertyProvider = fusionUtils.propertyProvider
local theme = require("@src/theme")

local baseImage = require("@components/base/imageLabel")

type props = {
	IconName: string,
	IconSize: number,
	Color: fusion.CanBeState<theme.color>?,
}

local function lucideIcon(props: props): ImageLabel
	local asset = lucide.GetAsset(props.IconName, props.IconSize)

	if asset == nil then
		return (nil :: any) :: ImageLabel
	end

	local component = baseImage({
		Name = "LucideIcon",
		Appearance = props.Color or Computed(function()
			return {
				color = theme.global.isDark:get() and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0),
				transparency = 0,
			}
		end),
		Image = asset.Url,
		BackgroundTransparency = 1,
		ImageRectOffset = asset.ImageRectOffset,
		ImageRectSize = asset.ImageRectSize,
		Size = UDim2.new(0, props.IconSize, 0, props.IconSize),
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "ImageLabel")) :: ImageLabel
end

return lucideIcon
