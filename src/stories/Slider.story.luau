local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local slider = require("@components/common/slider")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A slider that allows a single value to be selected between a minimum and maximum value.",
	controls = {
		Color = "red",
	},
	story = storyBase(function(parent: Frame, props)
		local topFrame = New("Frame")({
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(64, 64),
			Size = UDim2.fromOffset(300, 8),
			[Children] = {
				slider({
					Color = props.controls.Color,
					Min = 0,
					Max = 12,
					Tooltip = true,
					Value = 8,
					Width = UDim.new(0.5, 0),
				}),
			},
		})

		topFrame.Parent = parent

		return function()
			topFrame:Destroy()
		end
	end),
}
