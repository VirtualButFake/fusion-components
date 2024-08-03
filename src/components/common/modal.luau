local fusion = require("@packages/fusion")

local Children = fusion.Children
local New = fusion.New

local Computed = fusion.Computed
local Observer = fusion.Observer

local fusionUtils = require("@packages/fusionUtils")
local awaitLayer = fusionUtils.awaitLayer
local topLayerProvider = fusionUtils.topLayerProvider
local onDestroy = fusionUtils.onDestroy

local theme = require("@src/theme")

local baseButton = require("@components/base/button")

local popover = require("@components/common/popover")

type props = {
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	PopoverAppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Visible: fusion.StateObject<boolean>,
	Content: fusion.CanBeState<{ any }>,
	Padding: fusion.CanBeState<UDim>?,
	OnClickBesides: (() -> nil)?,
}

local function modal(object: GuiObject, props: props): GuiObject
	local useColor = theme:get("modal", "gray", "default", "Base", props.AppearanceOverride)

	awaitLayer(object, function(layer)
		local backLayer = baseButton({
			Name = "ModalContainer",
			Appearance = Computed(function()
				local color = useColor("Background")

				if not props.Visible:get() then
					color.transparency = 1
				end

				return color
			end),
			CornerRadius = 0,
			DisableHoverLighting = true,
			OnClick = props.OnClickBesides,
			Size = UDim2.new(1, 0, 1, 0),
		})

		local instance, newLayer = topLayerProvider.new(backLayer)
		instance.ZIndex = 999

		popover(backLayer, {
			Variant = "default",
			AppearanceOverride = props.PopoverAppearanceOverride,
			Visible = props.Visible,
			Padding = props.Padding,
			-- We cannot use the default positioning method (anchorpoint 0.5, 0.5, position etc), as this messes up automaticsize???
			-- so I present to you this hacky solutio,
			Content = props.Content,
			Wrapper = function(popoverFrame)
				return New("Frame")({
					Name = "ModalWrapper",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					[Children] = {
						New("UIListLayout")({
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0, 0),
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}),
						popoverFrame,
					},
				})
			end,
		})

		local function updateVisibility()
			if not props.Visible:get(false) then
				task.delay(0.3, function()
					if props.Visible:get(false) == false then
						layer:remove(instance)
					end
				end)
			else
				layer:add(instance)
			end
		end

		local disconnect = Observer(props.Visible):onChange(updateVisibility)
		updateVisibility()

		onDestroy(object, { disconnect, newLayer })
	end)

	return object
end

return modal
