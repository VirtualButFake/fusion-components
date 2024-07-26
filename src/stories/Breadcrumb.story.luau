local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local Value = fusion.Value

local breadcrumb = require("@components/common/breadcrumb")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A breadcrumb component, useful for allowing users to navigate through a hierarchy of pages.",
	controls = {
		Color = "emerald",
	},
	story = storyBase(function(parent: Frame, props)
		local labels
		local count = 0

		labels = Value({
			{
				Text = "Home",
				Icon = "home",
				OnClick = function()
					count += 1
					local oldLabels = labels:get()
					labels:set({
						oldLabels[1],
						oldLabels[2],
						{
							Text = "Breadcrumb " .. count,
							Icon = "link",
						},
					})
				end,
			},
			{
				Text = "About",
				Icon = "info",
				OnClick = function()
					count += 1
					local oldLabels = labels:get()
					labels:set({
						oldLabels[1],
						oldLabels[2],
					})
				end,
			},
			{
				Text = "Contact",
				Icon = "mail",
			},
		})

		local component = breadcrumb({
			Color = props.controls.Color,
			Labels = labels,
		})

		local container = New("Frame")({
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			[Children] = { component },
		})

		container.Parent = parent

		return function()
			container:Destroy()
		end
	end),
}
