local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local progress = require("@components/common/progressBar")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "The progress bar component in an indeterminate state, animating back and forth to signify loading.",
	controls = {
		Color = "red",
	},
	story = storyBase(function(parent: Frame, props)
		local component = New("Frame")({
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 4, 0, 4),
			Size = UDim2.new(0, 150, 0, 8),
			[Children] = {
				progress({
					Color = props.controls.Color,
					Indeterminate = true,
				}),
			},
		})

		component.Parent = parent

		return function()
			component:Destroy()
		end
	end),
}
