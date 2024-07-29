local fusion = require("@packages/fusion")
local Computed = fusion.Computed
local Observer = fusion.Observer
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local awaitLayer = fusionUtils.awaitLayer
local getState = fusionUtils.getState
local onDestroy = fusionUtils.onDestroy

local theme = require("@src/theme")

local menu = require("./menu")

type props = {
	Color: fusion.CanBeState<string>,
	Variant: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Enabled: fusion.CanBeState<boolean>?,
	Visible: fusion.Value<boolean>?,
	VisibleLogic: ((toOpen: boolean) -> boolean)?,
	Options: { { menu.option } },
	-- internal use
	Position: {
		X: fusion.CanBeState<number>?,
		Y: fusion.CanBeState<number>?,
	}?,
	StateOutput: {
		Size: fusion.Value<Vector2>?,
		Menu: menu.menu,
		ResetPosition: fusion.Value<boolean>?,
	}?,
	ParentMenu: menu.menu?,
}

local function contextMenu(object: GuiObject, props: props): GuiObject
	awaitLayer(object, function(layer)
		local parentAbsolutePosition = Value(layer.referenceLayer.AbsolutePosition)
		local parentAbsoluteSize = Value(layer.referenceLayer.AbsoluteSize)

		local isHovering = Value(false)
		local isVisible = getState(props.Visible or false)
		local resetPosition = getState(props.StateOutput and props.StateOutput.ResetPosition or false)
		local isMenuVisible = Computed(function()
			if props.Enabled == nil then
				return true
			end

			local wouldBeEnabled = typeof(props.Enabled) == "table" and props.Enabled:get() or props.Enabled

			if not wouldBeEnabled and isVisible:get() then
				if props.VisibleLogic == nil or props.VisibleLogic(false) then
					isVisible:set(false)
				end
			end

			return wouldBeEnabled
		end)

		local connections = {
			object.InputEnded:Connect(function(input, gp)
				if gp then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseButton2 and isMenuVisible:get() then
					if props.VisibleLogic == nil or props.VisibleLogic(true) then
						if not isVisible:get() then
							isVisible:set(true)
						else
							resetPosition:set(true)
						end
					end
				end
			end),
			layer.contentFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				parentAbsolutePosition:set(layer.referenceLayer.AbsolutePosition)
			end),
			layer.contentFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				parentAbsoluteSize:set(layer.referenceLayer.AbsoluteSize)
			end),
			Observer(layer.state.mouseDown):onChange(function()
				if layer.state.mouseDown:get() and isVisible:get() and not isHovering:get() then
					if props.VisibleLogic == nil or props.VisibleLogic(false) then
						isVisible:set(false)
					end
				end
			end),
			Observer(isMenuVisible):onChange(function()
				if not isMenuVisible:get() and isVisible:get() then
					isVisible:set(false)
				end
			end),
			object.MouseEnter:Connect(function()
				isHovering:set(true)
			end),
			object.MouseLeave:Connect(function()
				isHovering:set(false)
			end),
		}

		local createdMenu = menu({
			Name = "ContextMenu",
			Color = props.Color,
			Variant = props.Variant,
			AppearanceOverride = props.AppearanceOverride,
			Layer = layer,
			State = {
				ParentPosition = parentAbsolutePosition,
				ParentSize = parentAbsoluteSize,
				MenuSize = props.StateOutput and props.StateOutput.Size or Value(Vector2.new()),
				ResetPosition = resetPosition,
				Visible = isVisible,
				ParentMenu = {
					Menu = props.ParentMenu,
					Visible = isVisible,
				},
			},
			CreateNewMenu = contextMenu,
			Options = props.Options,
			Position = props.Position,
		})

		onDestroy(object, { connections, createdMenu })
	end)

	return object
end

return contextMenu
