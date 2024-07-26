local fusion = require("@packages/fusion")
local Value = fusion.Value

local input = require("@components/common/input")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "An input component for text. Automatically modifies cursor to indicate text input.",
	controls = {
		Color = "gray",
		Variant = "outline",
		Text = "Default text",
		Icon = "search",
		Disabled = false,
	},
	story = storyBase(function(parent: Frame, props)
        local inputText = Value(props.Controls.Text)

		local component = input({
			Color = props.controls.Color,
			Variant = props.controls.Variant,
			Disabled = props.controls.Disabled,
			Placeholder = "Placeholder",
			Icon = {
				Name = props.controls.Icon,
				Size = 16,
			},
			Text = inputText,
			OnTextChanged = function(text)
				print("Text changed:", text)
			end,
			OnFocusLost = function(text, enterPressed)
				print("Focus lost:", text, enterPressed)
                inputText:set(text)
			end,
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.fromOffset(100, 24),
		})

		component.Parent = parent

		return function()
			component:Destroy()
		end
	end),
}
