local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local Value = fusion.Value

local selectMenu = require("@components/common/selectMenu")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A select menu, allowing multiple values to be selected, created and searched.",
	controls = {
		Color = "gray",
		Variant = "outline",
		Disabled = false,
	},
	story = storyBase(function(parent: Frame, props)
		local options = Value({
			{
				Id = "Value 1",
			},
			{
				Id = "Value 2",
			},
			{
				Id = "Value 3",
			},
			{
				Id = "Value 4",
			},
			{
				Id = "Value 5",
			},
		})

		local selectedOptions = Value({
			"Value 1",
		})

		local topFrame = New("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(300, 300),
			[Children] = {
				selectMenu({
					Color = props.controls.Color,
					Variant = props.controls.Variant,
					Disabled = props.controls.Disabled,
					MaxHeight = 4,
					Options = options,
					Creatable = true,
					OnCreate = function(query)
						local currentOptions = options:get()
						table.insert(currentOptions, {
							Id = query,
						})

						options:set(currentOptions)
					end,
					OnOptionClicked = function(option)
						local currentSelectedOptions = table.clone(selectedOptions:get())
						local index = table.find(currentSelectedOptions, option)

						if index then
							table.remove(currentSelectedOptions, index)
						else
							table.insert(currentSelectedOptions, option)
						end

						selectedOptions:set(currentSelectedOptions)
					end,
					Position = UDim2.fromOffset(54, 54),
					SelectedOptions = selectedOptions,
					Size = UDim2.fromOffset(100, 20),
					Searchable = true,
				}),
			},
		})

		topFrame.Parent = parent

		return function()
			topFrame:Destroy()
		end
	end),
}
