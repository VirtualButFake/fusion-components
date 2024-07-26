local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local tooltip = require("@components/common/tooltip")
local button = require("@components/common/button")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A tooltip component, to provide additional information on actions.",
    controls = {
        Variant = "default",
    },
	story = storyBase(function(parent: Frame, props)
		local component = New("Frame")({
			AnchorPoint = Vector2.new(0, 0),
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 500, 0, 200),
			[Children] = {
				tooltip(
					button({
						Color = "red",
						ButtonText = "Hover over me for a tooltip!",
						Icon = {
							Name = "mouse-pointer",
							Size = 16,
						},
						AutomaticSize = Enum.AutomaticSize.XY,
						OnClick = function()
							print("Clicked")
						end,
						Variant = "solid",
					}),
					{
						Variant = props.controls.Variant,
						Text = "Tooltip",
						FollowMouse = true,
					}
				),
			},
		})

		component.Parent = parent

		return function()
			component:destroy()
		end
	end),
}
