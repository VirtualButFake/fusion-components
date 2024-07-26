local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local Value = fusion.Value

local inputMenu = require("@components/common/inputMenu")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "An input menu, allowing one selected option from a list of options. The list can be filtered by a query.",
	controls = {
		Color = "gray",
		Variant = "outline",
		Disabled = false,
	},
	story = storyBase(function(parent: Frame, props)
		local topFrame = New("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(300, 300),
			[Children] = {
				inputMenu({
					Color = props.controls.Color,
					Variant = props.controls.Variant,
					Disabled = props.controls.Disabled,
					MaxHeight = 3,
					OnOptionSelected = function(id)
						print(id)
					end,
					Options = {
						{
							Id = "Value 1",
						},
						{
							Id = "Value 2",
						},
						{
							Id = "Value 3",
							Icon = "check",
						},
						{
							Id = "Value 4",
						},
						{
							Id = "Value 5",
						},
						{
							Id = "Value 6",
						},
					},
					Placeholder = "Placeholder",
					Position = UDim2.fromOffset(54, 54),
					Query = "val",
					SelectedOption = Value("lol"),
					Size = UDim2.fromOffset(100, 20),
				}),
			},
		})

		topFrame.Parent = parent

		return function()
			topFrame:Destroy()
		end
	end),
}
