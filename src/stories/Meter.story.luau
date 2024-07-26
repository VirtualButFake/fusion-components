local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local Value = fusion.Value

local meter = require("@components/common/meter")
local button = require("@components/common/button")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A meter to track one or multiple values, with optional labels and icons.",
	controls = {},
	story = storyBase(function(parent: Frame)
		local values = {
			Value(0.2),
			Value(0.4),
			Value(0.3),
		}

		local component = New("Frame")({
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 4, 0, 4),
			Size = UDim2.new(0, 150, 0, 8),
			[Children] = {
				button({
					Color = "red",
					Variant = "solid",
					ButtonText = "randomize values",
					AutomaticSize = Enum.AutomaticSize.XY,
					OnClick = function()
						-- generate values, max of all values combined is 1
						local sum = 0

						for i = 1, 3 do
							values[i]:set(math.random() * (1 - sum))
							sum = sum + values[i]:get()
						end
					end,
					Position = UDim2.new(0, 160, 0, 0),
				}),
				meter({
					Indicator = true,
					Labels = {
						{
							Value = values[1],
							Label = "CPU Usage",
							Color = "red",
							Icon = "server",
						},
						{
							Value = values[2],
							Label = "GPU Usage",
							Color = "amber",
							Icon = "file-video",
						},
						{
							Value = values[3],
							Label = "Memory Usage",
							Color = "blue",
							Icon = "memory-stick",
						},
					},
				}),
			},
		})

		component.Parent = parent

		return function()
			component:Destroy()
		end
	end),
}
