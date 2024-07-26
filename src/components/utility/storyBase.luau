local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local Computed = fusion.Computed

local fusionUtils = require("@packages/fusionUtils")
local topLayerProvider = fusionUtils.topLayerProvider

local theme = require("@src/theme")

type props = {
	controls: {
		Width: number,
		Height: number,
	},
	Children: fusion.CanBeState<{ Instance }>?,
}

local function storyBase(
	componentFunction: (parent: Frame, props: { [string]: any }) -> any
): (parent: Frame, props: props) -> any
	return function(parent, props)
		local controls = props.controls or {}

		local frame = New("Frame")({
			BackgroundColor3 = Computed(function()
				return theme.global.isDark:get() and Color3.fromRGB(22, 22, 24) or Color3.fromRGB(255, 255, 255)
			end),
			Size = UDim2.new(
				controls.Width == nil and 1 or 0,
				controls.Width or 0,
				controls.Height == nil and 1 or 0,
				controls.Height or 0
			),
			[Children] = props.Children,
		})

		local topLayer = topLayerProvider.new(frame)
		topLayer.Parent = parent

		local componentDestructor = componentFunction(frame, props)

		return function()
			topLayer:Destroy()
			componentDestructor()
		end
	end
end

return storyBase
