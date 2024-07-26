local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local range = require("@components/common/range")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A range, useful for selecting a range of values instead of a single value.",
	controls = {
		Color = "red",
	},
	story = storyBase(function(parent: Frame, props)
		local topFrame = New("Frame")({
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(64, 64),
			Size = UDim2.fromOffset(300, 300),
			[Children] = {
				range({
					Color = props.controls.Color,
					Width = UDim.new(0.5, 0),
					Min = 0,
					Max = 10,
                    Step = 1,
                    VisualizeSteps = true,
					Tooltip = true,
					Value = { 2, 6 },
				}),
			},
		})

		topFrame.Parent = parent

		return function()
			topFrame:Destroy()
		end
	end),
}
