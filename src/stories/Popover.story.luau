local fusion = require("@packages/fusion")
local New = fusion.New

local popover = require("@components/common/popover")
local baseText = require("@components/base/text")
local storyBase = require("@components/utility/storyBase")

return {
	controls = {
		Variant = "default",
	},
	story = storyBase(function(parent: Frame, props)
		local frame = New("Frame")({
			BackgroundTransparency = 1,
		})

		popover(frame, {
			Variant = props.controls.Variant,
			Visible = true,
			Padding = UDim.new(0, 8),
			Content = function(useColor)
				return baseText({
					Appearance = useColor("Text", true),
					Text = "Hello, world!",
					AutomaticSize = Enum.AutomaticSize.XY,
				})
			end,
		})

		frame.Parent = parent

		return function()
			frame:Destroy()
		end
	end),
}
