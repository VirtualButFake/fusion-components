local fusion = require("@packages/fusion")
local Spring = fusion.Spring

local New = fusion.New

local Computed = fusion.Computed
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local awaitLayer = fusionUtils.awaitLayer
local getState = fusionUtils.getState
local onDestroy = fusionUtils.onDestroy
local use = fusionUtils.use

local theme = require("@src/theme")

local baseText = require("@components/base/text")

local placementPopover = require("@components/utility/placementPopover")

type props = {
	Variant: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	FollowMouse: boolean?,
	RelativePosition: fusion.CanBeState<UDim2>?,
	Placement: placementPopover.placement?,
	Text: string? | baseText.text?,
	Visible: fusion.CanBeState<boolean>?,
	DisableHoverBehaviour: boolean?,
	Padding: fusion.CanBeState<UDim>?,
	Enabled: fusion.CanBeState<boolean>?,
	Slots: {
		Content: ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
	}?,
}

local function tooltip(object: GuiObject, props: props): GuiObject
	awaitLayer(object, function(layer)
		local useColor = theme:get("popover", "neutral", props.Variant, "Base", props.AppearanceOverride)

		local isVisible = getState(props.Visible or false)
		local mousePosition = layer.state.mousePosition
		local absolutePosition = Value(object.AbsolutePosition)
		local absoluteSize = Value(object.AbsoluteSize)

		local parentAbsolutePosition = Value(layer.referenceLayer.AbsolutePosition)
		local tooltipSize = Value(Vector2.new())

		if props.FollowMouse then
			props.Placement = nil
		end

		local targetPosition = Computed(function()
			local childAbsSize = absoluteSize:get()
			local parentAbsPosition = parentAbsolutePosition:get()

			if props.FollowMouse then
				local mousePos = mousePosition:get()

				return UDim2.new(0, mousePos.X - parentAbsPosition.X + 6, 0, mousePos.Y - parentAbsPosition.Y + 6)
			else
				local childAbsPosition = absolutePosition:get()

				return UDim2.new(
					0,
					childAbsPosition.X - parentAbsPosition.X + childAbsSize.X / 2,
					0,
					childAbsPosition.Y - parentAbsPosition.Y + childAbsSize.Y / 2
				)
			end
		end)

		local connections = {
			object:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				absolutePosition:set(object.AbsolutePosition)
			end),
			object:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				absoluteSize:set(object.AbsoluteSize)
			end),
			layer.contentFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				parentAbsolutePosition:set(layer.referenceLayer.AbsolutePosition)
			end),
			object.MouseEnter:Connect(function()
				if props.DisableHoverBehaviour then
					return
				end

				isVisible:set(true)
			end),
			object.MouseLeave:Connect(function()
				if props.DisableHoverBehaviour then
					return
				end

				isVisible:set(false)
			end),
		}

		local component = placementPopover(object, {
			Variant = props.Variant,
			AppearanceOverride = props.AppearanceOverride,
			ParentComponent = layer.referenceLayer,
			Content = props.Slots and props.Slots.Content and props.Slots.Content(useColor) or {
				New("UIPadding")({
					PaddingBottom = UDim.new(0, 2),
					PaddingLeft = UDim.new(0, 2),
					PaddingRight = UDim.new(0, 2),
					PaddingTop = UDim.new(0, 2),
				}),
				New("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Padding = UDim.new(0, 4),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),
				props.Text and baseText({
					Name = "TooltipText",
					Appearance = useColor("Text", true),
					Text = props.Text,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					RichText = true,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
				}) or nil,
			},
			Padding = props.Padding,
			Placement = props.Placement,
			PopoverSize = tooltipSize,
			PositionAnimation = use(props.Placement) and true or false,
			RelativePosition = Spring(
				Computed(function()
					if props.Placement then
						return use(props.RelativePosition)
					end

					-- FollowMouse behaviour
					if isVisible:get() then
						return targetPosition:get() + (use(props.RelativePosition) or UDim2.new())
					else
						return targetPosition:get()
					end
				end),
				25,
				1
			),
			Visible = props.Enabled and Computed(function()
				return use(props.Enabled) and isVisible:get()
			end) or isVisible,
		})

		onDestroy(object, {
			connections,
			function()
				layer:remove(component)
				component:Destroy()
			end,
		})
	end)

	return object
end

return tooltip
