local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New

local Value = fusion.Value

local modal = require("@components/common/modal")
local button = require("@components/common/button")
local storyBase = require("@components/utility/storyBase")

return {
	summary = "A modal, useful for displaying content on top of the current page. Layers behind the modal are not interactable.",
	controls = {},
	story = storyBase(function(parent: Frame)
		local isOpen = Value(false)

		local topFrame = New("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(300, 300),
			[Children] = {
				modal(
					button({
						Color = "gray",
						Variant = "solid",
						ButtonText = "Click me to open the modal",
						AutomaticSize = Enum.AutomaticSize.XY,
						OnClick = function()
							isOpen:set(true)
						end,
						Position = UDim2.fromOffset(4, 4),
					}),
					{
						Visible = isOpen,
						Content = {
							button({
								Color = "gray",
								Variant = "solid",
								ButtonText = "Click me to close this modal",
								AutomaticSize = Enum.AutomaticSize.XY,
								OnClick = function()
									isOpen:set(false)
								end,
							}),
						},
					}
				),
			},
		})

		topFrame.Parent = parent

		return function()
			topFrame:Destroy()
		end
	end),
}
