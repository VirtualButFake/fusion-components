local fusion = require("@packages/fusion")
local Value = fusion.Value

local checkbox = require("@components/common/checkbox")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A simple checkbox for toggling a boolean value.",
	controls = {
		Color = "red",
		Disabled = false,
	},
	story = storyBase(function(parent: Frame, props)
		local CheckboxState = Value(false)
		local component = checkbox({
			Color = props.controls.Color,
			Disabled = props.controls.Disabled,
			State = CheckboxState,
			OnClick = function()
				CheckboxState:set(not CheckboxState:get(false))
			end,
			Position = UDim2.fromOffset(4, 4),
		})

		component.Parent = parent

		return function()
			component:Destroy()
		end
	end),
}
