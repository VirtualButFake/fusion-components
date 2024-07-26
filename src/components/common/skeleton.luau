local RunService = game:GetService("RunService")

local fusion = require("@packages/fusion")

local Cleanup = fusion.Cleanup
local Hydrate = fusion.Hydrate

local Computed = fusion.Computed
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local propertyProvider = fusionUtils.propertyProvider
local use = fusionUtils.use
local peek = fusionUtils.peek

local theme = require("@src/theme")

local baseFrame = require("@components/base/frame")

type props = {
	CornerRadius: fusion.CanBeState<UDim>?,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Animated: fusion.CanBeState<boolean>?,
}

local function skeleton(props: props): Frame
	local useColor = theme:get("skeleton", "gray", "default", "Base", props.AppearanceOverride)

	local timer = Value(0)

	local updateConnection = RunService.RenderStepped:Connect(function(dt)
		if not peek(props.Animated) then
			return
		end

		timer:set(timer:get() + dt)
	end)

	local component = baseFrame({
		Appearance = Computed(function()
			if not use(props.Animated) then
				return useColor("Background")
			end

			return timer:get() % 2 > 1 and useColor("Background") or useColor("Animation")
		end),
		CornerRadius = props.CornerRadius,
		[Cleanup] = { updateConnection },
		TweenSettings = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "Frame"))
end

return skeleton
