local fusion = require("@packages/fusion")
local Children = fusion.Children
local New = fusion.New
local Ref = fusion.Ref

local Value = fusion.Value
local Computed = fusion.Computed

local fusionUtils = require("@packages/fusionUtils")
local sizeFromLayer = fusionUtils.sizeFromLayer

local contextMenu = require("@components/common/contextMenu")
local tooltip = require("@components/common/tooltip")
local storyBase = require("@components/utility/storyBase")
local modal = require("@components/common/modal")
local colorPicker = require("@components/common/colorPicker")

return {
	summary = "A dynamic context menu, supporting nested options and dynamic updates. Wrapping an option allows for tooltips and other customizations.",
	controls = {
		Color = "red",
		Variant = "default",
	},
	story = storyBase(function(parent: Frame, props)
		local children = fusion.Value({})
		local component = New("Frame")({
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 500, 0, 300),
			[Children] = children,
		})

		component.Parent = parent

		local isOpenState = Value(false)
		local isModalOpen = Value(false)

		local value = Value({
			{
				{
					Label = "Create",
					Icon = "plus",
				},
				{
					Label = "Edit",
					Icon = "pencil",
					Options = {
						{
							{
								Label = "Rename",
								Disabled = true,
								Icon = "pen",
							},
							{
								Label = "Color",
								Icon = "palette",
								Callback = function()
									isModalOpen:set(true)
								end,
								Slots = {
									Wrapper = function(_, _, menuEntry)
										local colorPickerPopover = Value()

										return modal(menuEntry, {
											Visible = isModalOpen,
											Content = {
												New("Frame")({
													Name = "ColorPickerPopover",
													BackgroundTransparency = 1,
													Size = sizeFromLayer(
														colorPickerPopover,
														UDim2.new(0.8, -16, 0.8, -16)
													),
													[Ref] = colorPickerPopover,
													[Children] = {
														New("UIAspectRatioConstraint")({
															AspectRatio = 0.75,
														}),
														New("UISizeConstraint")({
															MinSize = Vector2.new(200, 200),
														}),
														colorPicker({
															Color = "red",
															Value = Color3.fromRGB(0, 255, 0),
															Variant = "default",
														}),
													},
												}),
											},
											OnClickBesides = function()
												isModalOpen:set(false)
											end,
											Padding = UDim.new(0, 4),
										})
									end,
								},
							},
						},
					},
				},
			},
			{
				{
					Icon = "trash",
					Label = "Delete",
					Slots = {
						Wrapper = function(_, _, menuEntry)
							return tooltip(menuEntry, {
								Variant = "default",
								FollowMouse = true,
								Text = "Clicking this will delete the element",
								Padding = UDim.new(0, 8),
							})
						end,
					},
					Callback = function()
						return -1
					end,
				},
			},
		})

		children:set({
			contextMenu(
				New("Frame")({
					Name = "Holder",
					BackgroundTransparency = 1,
					Size = UDim2.new(0.5, 0, 0.5, 0),
					[Children] = {
						New("UICorner")({
							CornerRadius = UDim.new(0, 16),
						}),
						New("TextLabel")({
							Name = "ClickText",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							Font = Enum.Font.SourceSansSemibold,
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(0.8, 0, 0.5, 0),
							Text = Computed(function()
								return ""
							end),
							TextSize = 16,
							TextWrapped = true,
						}),
					},
				}),
				{
					Color = props.controls.Color,
					Variant = props.controls.Variant,
					Visible = isOpenState,
					Options = value,
				}
			),
		})

		return function()
			component:destroy()
		end
	end),
}
