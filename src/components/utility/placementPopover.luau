local fusion = require("@packages/fusion")
local Spring = fusion.Spring

local Cleanup = fusion.Cleanup

local Computed = fusion.Computed
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local topLayerProvider = fusionUtils.topLayerProvider
local use = fusionUtils.use

local theme = require("@src/theme")

local popover = require("@components/utility/popover")

local function getPlacementOffset(placement: UDim2, size: Vector2)
	return UDim2.fromOffset(size.X * placement.X.Scale, size.Y * placement.Y.Scale)
end

local placementOffsets: {
	[string]: {
		anchorPoint: Vector2,
		position: UDim2,
		paddingMultiplier: Vector2,
	},
} =
	{
		left = {
			anchorPoint = Vector2.new(1, 0.5),
			position = UDim2.fromScale(0, 0.5),
			paddingMultiplier = Vector2.new(-1, 0),
		},
		right = {
			anchorPoint = Vector2.new(0, 0.5),
			position = UDim2.fromScale(1, 0.5),
			paddingMultiplier = Vector2.new(1, 0),
		},
		top = {
			anchorPoint = Vector2.new(0.5, 1),
			position = UDim2.fromScale(0.5, 0),
			paddingMultiplier = Vector2.new(0, -1),
		},
		bottom = {
			anchorPoint = Vector2.new(0.5, 0),
			position = UDim2.fromScale(0.5, 1),
			paddingMultiplier = Vector2.new(0, 1),
		},
		["bottom-left"] = {
			anchorPoint = Vector2.new(1, 0),
			position = UDim2.fromScale(0, 1),
			paddingMultiplier = Vector2.new(-1, 1),
		},
		["bottom-right"] = {
			anchorPoint = Vector2.new(0, 0),
			position = UDim2.fromScale(1, 1),
			paddingMultiplier = Vector2.new(1, 1),
		},
		["top-left"] = {
			anchorPoint = Vector2.new(1, 1),
			position = UDim2.fromScale(0, 0),
			paddingMultiplier = Vector2.new(-1, -1),
		},
		["top-right"] = {
			anchorPoint = Vector2.new(0, 1),
			position = UDim2.fromScale(1, 0),
			paddingMultiplier = Vector2.new(1, -1),
		},
	}

export type placement = "left" | "right" | "top" | "bottom" | "bottom-left" | "bottom-right" | "top-left" | "top-right"

export type props = {
	Color: fusion.CanBeState<string>?,
	Variant: fusion.CanBeState<string>?,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	ParentComponent: GuiObject,
	Content: fusion.CanBeState<{ any }>?
		| ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
	Visible: fusion.CanBeState<boolean>,
	PopoverSize: fusion.Value<Vector2>?,
	Appearance: fusion.CanBeState<theme.color>?,
	Stroke: fusion.CanBeState<theme.color>?,
	CornerRadius: fusion.CanBeState<number>?,
	Padding: fusion.CanBeState<UDim>?,
	Margin: fusion.CanBeState<number>?,
	Placement: placement | nil,
	PositionAnimation: fusion.CanBeState<boolean>?,
	RelativePosition: fusion.CanBeState<UDim2>?,
	Wrapper: ((popoverFrame: GuiObject) -> GuiObject)?,
	[any]: any,
}

local DEFAULT_MARGIN = 4

-- this is just a wrapper for a popover that has internally managed position
local function placementPopover(object: GuiObject, props: props): GuiObject?
	if props.Placement == nil then
		if props.RelativePosition and props.Position == nil then
			props.Position = props.RelativePosition
		end

		return popover(props)
	end

	local layer = topLayerProvider.getLayer(props.ParentComponent or object)

	if not layer then
		return object
	end

	local absolutePosition = Value(object.AbsolutePosition)
	local absoluteSize = Value(object.AbsoluteSize)
	local parentAbsolutePosition = Value(props.ParentComponent.AbsolutePosition)

	local popoverSize = props.PopoverSize or Value(Vector2.new(0, 0))
	props.PopoverSize = popoverSize

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
	}

	props.AnchorPoint = Computed(function()
		local placementValue = placementOffsets[use(props.Placement)]
		return placementValue.anchorPoint
	end)

	props.Position = Spring(
		Computed(function()
			local parentAbsPosition = parentAbsolutePosition:get()
			local childAbsPosition = absolutePosition:get()

			local placementValue = placementOffsets[use(props.Placement)]
			local placementOffset = getPlacementOffset(placementValue.position, absoluteSize:get())
			local padding = placementValue.paddingMultiplier
				* Vector2.new(use(props.Margin) or DEFAULT_MARGIN, use(props.Margin) or DEFAULT_MARGIN)
			local relativePosition = use(props.RelativePosition) or UDim2.new(0, 0, 0, 0)

			if use(props.PositionAnimation) and use(props.Visible) then
				return UDim2.new(
					0,
					childAbsPosition.X - parentAbsPosition.X,
					0,
					childAbsPosition.Y - parentAbsPosition.Y
				) + placementOffset + UDim2.fromOffset(padding.X, padding.Y) + relativePosition
			end

			return UDim2.new(0, childAbsPosition.X - parentAbsPosition.X, 0, childAbsPosition.Y - parentAbsPosition.Y)
				+ placementOffset
				+ UDim2.fromOffset(-padding.X, -padding.Y)
				+ relativePosition
		end),
		30,
		1
	)

	props[Cleanup] = connections

	return popover(props)
end

return placementPopover
