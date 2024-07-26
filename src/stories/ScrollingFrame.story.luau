local fusion = require("@packages/fusion")
local New = fusion.New

local scrollingFrame = require("@components/common/scrollingFrame")
local button = require("@components/common/button")
local storyBase = require("@components/utility/storyBase")

return {
	controls = {
		Variant = "default",
	},
	story = storyBase(function(parent: Frame)
		local frame = scrollingFrame({
			Content = {
				New("UIListLayout")({
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, 8),
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),
				(function()
					local buttons = {}

					for _ = 1, 50 do
						table.insert(
							buttons,
							button({
								Color = "emerald",
								Variant = "solid",
								ButtonText = "Hello, world!",
								AutomaticSize = Enum.AutomaticSize.XY,
							})
						)
					end

					return buttons
				end)(),
			},
			Position = UDim2.new(0, 4, 0, 4),
			ScrollingFrameProps = {
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
			},
			Size = UDim2.new(0, 100, 0, 200),
		})

		frame.Parent = parent

		return function()
			frame:Destroy()
		end
	end),
}
