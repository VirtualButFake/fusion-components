local fusion = require("@packages/fusion")

local fusionUtils = require("@packages/fusionUtils")
local awaitLayer = fusionUtils.awaitLayer
local onDestroy = fusionUtils.onDestroy

local theme = require("@src/theme")

local placementPopover = require("@components/utility/placementPopover")

type props = {
	Variant: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Placement: placementPopover.placement?,
	Visible: fusion.CanBeState<boolean>,
	Padding: fusion.CanBeState<UDim>?,
	Content: fusion.CanBeState<{ any }> | ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>),
	PositionAnimation: boolean?,
	Wrapper: ((popoverFrame: GuiObject) -> GuiObject)?,
}

local function popover(object: GuiObject, props: props): GuiObject
	awaitLayer(object, function(layer)
		local passedProps = {
			Variant = props.Variant,
			AppearanceOverride = props.AppearanceOverride,
			ParentComponent = layer.referenceLayer,
			Content = props.Content,
			Visible = props.Visible,
			Padding = UDim.new(0, 2),
			Placement = props.Placement,
			PositionAnimation = props.PositionAnimation or true,
			Wrapper = props.Wrapper,
		}

		for i, prop in props do
			passedProps[i] = prop
		end

		local component = placementPopover(object, passedProps)

		onDestroy(object, { component })
	end)

	return object
end

return popover
