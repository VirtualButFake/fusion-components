local badge = require("@components/common/badge")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A badge component, to represent various things quickly and easily.",
	controls = {
		Color = "blue",
		Variant = "solid",
		Text = "Server",
		Icon = "server",
	},
	story = storyBase(function(parent: Frame, props)
		local component = badge({
			Color = props.controls.Color,
			Variant = props.controls.Variant,
			Text = props.controls.Text,
			Icon = props.controls.Icon ~= "" and {
				Name = props.controls.Icon,
				Size = 16,
			} or nil,
		})

		component.Parent = parent

		return function()
			component:Destroy()
		end
	end),
}
