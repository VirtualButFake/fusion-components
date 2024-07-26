local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local Value = fusion.Value

local progress = require("@components/common/progressBar")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "The progress bar component with a progress indicator, used when the progress is known.",
	controls = {
		Color = "red",
	},
	story = storyBase(function(parent: Frame, props)
		local progressValue = Value(4)

		local component = New("Frame")({
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 24, 0, 0),
			Size = UDim2.new(0, 150, 0, 8),
			[Children] = {
				progress({
					Color = props.controls.Color,
					Progress = progressValue,
					Indicator = true,
					Max = 10,
				}),
				--[[
                    button({
					Color = "gray",
					Variant = "solid",
					ButtonText = "Click me to increase progress",
					AutomaticSize = Enum.AutomaticSize.XY,
					Position = UDim2.fromOffset(0, 32),
					OnClick = function()
						local currentValue = progressValue:get()

						if currentValue >= 10 then
							currentValue = -1
						end

						progressValue:set(math.min(currentValue + 1, 10))
					end,
				}),
                ]]
			},
		})

		component.Parent = parent

		return function()
			component:Destroy()
		end
	end),
}
