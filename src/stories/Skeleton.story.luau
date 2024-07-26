local fusion = require("@packages/fusion")
local New = fusion.New
local Children = fusion.Children

local skeleton = require("@components/common/skeleton")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A skeleton component, useful for representing loading states. Can be used alongside the Await component to display temporary content.",
	controls = {},
	story = storyBase(function(parent: Frame)
		local component = New("Frame")({
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 16),
			Size = UDim2.new(0, 300, 0, 300),
			[Children] = {
				skeleton({
					CornerRadius = UDim.new(0, 4),
					Animated = true,
					Size = UDim2.new(0, 150, 0, 16),
				}),
				skeleton({
					CornerRadius = UDim.new(0, 4),
					Animated = true,
					Position = UDim2.fromOffset(0, 20),
					Size = UDim2.new(0, 100, 0, 16),
				}),
				skeleton({
					CornerRadius = UDim.new(0, 8),
					Animated = true,
					Position = UDim2.fromOffset(0, 48),
					Size = UDim2.new(0, 150, 0, 50),
				}),
			},
		})

		component.Parent = parent

		return function()
			component:Destroy()
		end
	end),
}
