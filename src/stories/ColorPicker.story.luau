local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local colorPicker = require("@components/common/colorPicker")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A color picker featuring (customizable) preset colors and a color selector.",
	controls = {
		Color = "white",
	},
	story = storyBase(function(parent: Frame, props)
		local container = New("Frame")({
			Name = "Container",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(200, 260),
			[Children] = {
				colorPicker({
					Color = props.controls.Color,
					Value = Color3.fromRGB(0, 255, 0),
					Variant = "default",
				}),
			},
		})

		container.Parent = parent

		return function()
			container:Destroy()
		end
	end),
}
