local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local tabs = require("@components/common/tabs")
local button = require("@components/common/button")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A tab component, to switch between different sections of content.",
	controls = {
		Color = "red",
		Variant = "solid",
	},
	story = storyBase(function(parent: Frame, props)
		local Tab1 = {
			Label = "Tab 1",
			Content = {
				button({
					Color = "emerald",
					Variant = "solid",
					ButtonText = "Tab 1 content",
					OnClick = function()
						print("Clicked")
					end,
					AutomaticSize = Enum.AutomaticSize.XY,
					CornerRadius = 4,
					Position = UDim2.fromOffset(4, 4),
				}),
			},
		}

		local Tab2 = {
			Label = "Tab 2",
			Disabled = true,
			Content = {
				button({
					Color = "red",
					Variant = "solid",
					ButtonText = "Tab 2 content",
					OnClick = function()
						print("Clicked")
					end,
					AutomaticSize = Enum.AutomaticSize.XY,
					CornerRadius = 4,
					Position = UDim2.fromOffset(4, 4),
				}),
			},
		}

		local Tab3 = {
			Label = "Tab 3",
			Content = {
				button({
					Color = "indigo",
					Variant = "solid",
					ButtonText = "Tab 3 content",
					OnClick = function()
						print("Clicked")
					end,
					AutomaticSize = Enum.AutomaticSize.XY,
					CornerRadius = 4,
					Position = UDim2.fromOffset(4, 4),
				}),
			},
		}

		local component = New("Frame")({
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 4, 0, 4),
			Size = UDim2.new(0, 200, 0, 300),
			[Children] = {
				tabs({
					Color = props.controls.Color,
					Variant = props.controls.Variant,
					Tabs = { Tab1, Tab2, Tab3 },
				}),
			},
		})

		component.Parent = parent

		return function()
			component:Destroy()
		end
	end),
}
