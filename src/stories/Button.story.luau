local button = require("@components/common/button")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A simple extensible button component, with support for icons, text and various events.",
	controls = {
		Color = "red",
		Variant = "solid",
		Text = "Example text",
		Icon = "mouse-pointer-click",
		Disabled = false,
	},
	story = storyBase(function(parent: Frame, props)
		local component = button({
			Color = props.controls.Color,
			Variant = props.controls.Variant,
			Disabled = props.controls.Disabled,
			ButtonText = props.controls.Text,
			Icon = {
				Name = props.controls.Icon,
				Size = 16,
			},
			AutomaticSize = Enum.AutomaticSize.XY,
			OnClick = function()
				print("Clicked")
			end,
			Position = UDim2.fromOffset(4, 4),
		})

		component.Parent = parent

		return function()
			component:Destroy()
		end
	end),
}
