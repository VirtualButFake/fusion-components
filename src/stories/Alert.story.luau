local alert = require("@components/common/alert")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A versatile alert element to draw attention to important information.",
	controls = {
		Color = "amber",
		Variant = "solid",
		Title = "Warning!",
		Description = "This is an example alert!",
		Icon = "alert-triangle",
	},
	story = storyBase(function(parent: Frame, props)
		local component = alert({
			Color = props.controls.Color,
			Variant = props.controls.Variant,
			Title = props.controls.Title,
			Description = props.controls.Description,
			Icon = props.controls.Icon ~= "" and props.controls.Icon or nil,
			Position = UDim2.fromOffset(16, 16),
			Size = UDim2.new(0, 200, 0, 0),
		})

		component.Parent = parent

		return function()
			component:Destroy()
		end
	end),
}
