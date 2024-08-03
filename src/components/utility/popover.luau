local fusion = require("@packages/fusion")
local Spring = fusion.Spring

local Cleanup = fusion.Cleanup
local Hydrate = fusion.Hydrate
local Out = fusion.Out

local Clean = fusion.cleanup
local Computed = fusion.Computed
local Observer = fusion.Observer

local fusionUtils = require("@packages/fusionUtils")
local topLayerProvider = fusionUtils.topLayerProvider
local propertyProvider = fusionUtils.propertyProvider
local use = fusionUtils.use

local theme = require("@src/theme")

local sinkFrame = require("@components/base/sinkFrame")

local canvasFrame = require("@components/utility/canvasFrame")

export type props = {
	Color: fusion.CanBeState<string>?,
	Variant: fusion.CanBeState<string>?,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	ParentComponent: GuiObject,
	Position: fusion.CanBeState<UDim2>?,
	Content: fusion.CanBeState<{ any }>? | ((useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }>)?,
	Visible: fusion.CanBeState<boolean>,
	PopoverSize: fusion.Value<Vector2>?,
	Appearance: fusion.CanBeState<theme.color>?,
	Stroke: fusion.CanBeState<theme.color>?,
	CornerRadius: fusion.CanBeState<number>?,
	Padding: fusion.CanBeState<UDim>?,
	Wrapper: ((popoverFrame: GuiObject) -> GuiObject)?,
}

local function popover(props: props): Frame?
	local layer = topLayerProvider.getLayer(props.ParentComponent)

	if not layer then
		return nil
	end

	local useColor =
		theme:get("popover", props.Color or "neutral", props.Variant or "default", "Base", props.AppearanceOverride)

	local disconnect
	local popoverFrame
	popoverFrame = canvasFrame({
		Name = "Popover",
		GroupTransparency = Spring(
			Computed(function()
				return use(props.Visible) and 0 or 1
			end),
			22,
			1
		),
		Children = {
			sinkFrame({
				Name = "Content",
				Appearance = props.Appearance or useColor("Background", true),
				Stroke = props.Stroke or useColor("Stroke", true),
				CornerRadius = props.CornerRadius or 4,
				Padding = props.Padding or UDim.new(0, 4),
				AutomaticSize = Enum.AutomaticSize.XY,
				Content = typeof(props.Content) == "function" and Computed(function()
					local contentFunction: (useColor: theme.useColorFunction) -> fusion.CanBeState<{ any }> =
						props.Content
					return contentFunction(useColor)
				end, Clean) or props.Content,
			}),
		},
		AutomaticSize = Enum.AutomaticSize.XY,
		Position = props.Position,
		Shadow = useColor("Shadow", true),
		[Out("AbsoluteSize")] = props.PopoverSize,
		[Cleanup] = {
			function()
				Clean(disconnect)
				layer:remove(popoverFrame)
			end,
		},
	})

	local wrapperFrame = popoverFrame

	if props.Wrapper then
		wrapperFrame = props.Wrapper(popoverFrame)
	end

	if typeof(props.Visible) == "table" then
		local function updateVisibility()
			if use(props.Visible) then
				layer:add(wrapperFrame)
			else
				task.delay(0.4, function()
					if use(props.Visible) then
						return
					end

					layer:remove(wrapperFrame)
				end)
			end
		end

		disconnect = Observer(props.Visible):onChange(updateVisibility)
		task.spawn(updateVisibility)
	elseif use(props.Visible) then
		layer:add(wrapperFrame)
	end

	-- the component is hydrated w/ Visible, which toggles it's visibility which we don't want
	local clonedProps = table.clone(props)
	clonedProps.Visible = nil :: any

	return Hydrate(popoverFrame)(propertyProvider.getPropsAndSpecialKeys(clonedProps, "Frame")) :: Frame
end

return popover
