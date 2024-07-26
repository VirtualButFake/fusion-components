local fusion = require("@packages/fusion")

local Children = fusion.Children
local Hydrate = fusion.Hydrate
local New = fusion.New
local Out = fusion.Out

local Clean = fusion.cleanup
local Computed = fusion.Computed
local Observer = fusion.Observer
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use
local propertyProvider = fusionUtils.propertyProvider
local onDestroy = fusionUtils.onDestroy

local theme = require("@src/theme")

local shadow = require("@components/utility/shadow")

type props = {
	GroupTransparency: fusion.StateObject<number>,
	Visible: fusion.CanBeState<boolean>?,
	Children: fusion.CanBeState<{ any }>,
	Shadow: theme.color?,
}

local CANVAS_EPSILON = 0.00001
local TRANSPARENCY_EPSILON = 0.99999

local function canvasFrame(props: props): GuiObject
	local renderMode = Computed(function()
		if use(props.GroupTransparency) > TRANSPARENCY_EPSILON or use(props.Visible) == false then
			return "invisible"
		elseif use(props.GroupTransparency) > CANVAS_EPSILON then
			return "canvas"
		else
			return "frame"
		end
	end)

	local containerSize = Value()
	local isShadowVisible = Value(false)
	local computedShadow = Computed(function()
		local shadowValue = use(props.Shadow)
		if shadowValue and shadowValue.shadow and shadowValue.shadow ~= 0 then
			return shadow({
				Elevation = shadowValue.shadow,
				TargetSize = containerSize,
				Transparency = props.GroupTransparency,
			})
		end

		return
	end, Clean)

	local container = New("Frame")({
		Name = "CanvasFrame",
		BackgroundTransparency = 1,
		[Children] = {
			Computed(function()
				if isShadowVisible:get() then
					return computedShadow:get()
				end

				return
			end),
		},
	})

	local canvas = New("CanvasGroup")({
		Name = "Canvas",
		BackgroundTransparency = 1,
		GroupTransparency = props.GroupTransparency,
		Size = UDim2.new(1, 0, 1, 0),
	})

	local contentHolder = New("Frame")({
		Name = "ContentHolder",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		[Out("AbsoluteSize")] = containerSize,
		[Children] = {
			-- this could cause conflicts with padding, but has to be done to avoid strokes disappearing
			New("UIPadding")({
				PaddingBottom = UDim.new(0, 1),
				PaddingLeft = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 1),
				PaddingTop = UDim.new(0, 1),
			}),
			props.Children,
		},
	})

	local function updateContentType()
		local currentContentType = renderMode:get()

		container.Visible = currentContentType ~= "invisible"

		if currentContentType == "frame" then
			contentHolder.Parent = container
			canvas.Parent = nil
			isShadowVisible:set(true)
		elseif currentContentType == "canvas" then
			canvas.Parent = container

			local clonedChildren = contentHolder:Clone()
			clonedChildren.Parent = canvas
			task.wait()
			isShadowVisible:set(true)
			-- we yield, so the instance could be destroyed by the time we get to this, which would result in an error
			pcall(function()
				contentHolder.Parent = canvas
				clonedChildren:Destroy()
			end)
		elseif currentContentType == "invisible" then
			contentHolder.Parent = nil
			canvas.Parent = nil
			isShadowVisible:set(false)
		end
	end

	onDestroy(container, { Observer(renderMode):onChange(updateContentType) })
	task.spawn(updateContentType)

	return Hydrate(container)(propertyProvider.getPropsAndSpecialKeys(props, "Frame"))
end

return canvasFrame
