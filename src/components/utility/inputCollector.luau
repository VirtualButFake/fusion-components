-- a textbutton that spans across the entire layer, capturing input. intended to be used for expanding hitboxes, for ex. on i.e. sliders
local fusion = require("@packages/fusion")
local New = fusion.New
local Event = fusion.OnEvent

local Observer = fusion.Observer
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local awaitLayer = fusionUtils.awaitLayer
local use = fusionUtils.use
local onDestroy = fusionUtils.onDestroy

type props = {
	ReferenceObject: GuiObject,
	Visible: fusion.StateObject<boolean>,
	OnHover: ((hoverState: boolean) -> nil)?,
	OnMouseButton1Changed: ((isPressed: boolean, wasHover: boolean?) -> nil)?,
	OnClick: ((wasHover: boolean) -> nil)?,
	OnMouseMove: ((position: Vector2) -> nil)?,
	OnInputBegan: ((input: InputObject) -> nil)?,
	OnInputEnded: ((input: InputObject) -> nil)?,
	OnInputChanged: ((input: InputObject) -> nil)?,
}

local allCollectors = Value(0)
local activeCollectors = {}

local function inputCollector(props: props)
	awaitLayer(props.ReferenceObject, function(layer)
		local function setHover(hoverState: boolean)
			if props.OnHover then
				props.OnHover(hoverState)
			end
		end

		local function setPressed(isPressed: boolean, wasHover: boolean?)
			if props.OnMouseButton1Changed then
				props.OnMouseButton1Changed(isPressed, wasHover)
			end

			if not isPressed then
				if props.OnClick then
					props.OnClick(wasHover or false)
				end
			end
		end

		local zIndex = Value(0)

		local component = New("TextButton")({
			Name = "InputCollector",
			Active = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = zIndex,
			[Event("MouseButton1Down")] = function()
				setPressed(true)
			end,
			[Event("MouseButton1Up")] = function()
				setPressed(false)
			end,
			[Event("MouseEnter")] = function()
				setHover(true)
			end,
			[Event("MouseLeave")] = function()
				setHover(false)
				setPressed(false, true)
			end,
			[Event("InputChanged")] = function(input, gp)
				if gp then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseMovement and props.OnMouseMove then
					props.OnMouseMove(Vector2.new(input.Position.X, input.Position.Y))
				end

				if props.OnInputChanged then
					props.OnInputChanged(input)
				end
			end,
			[Event("InputBegan")] = props.OnInputBegan and function(input, gp)
				if gp then
					return
				end

				if props.OnInputBegan then
					props.OnInputBegan(input)
				end
			end or nil,
			[Event("InputEnded")] = props.OnInputEnded and function(input, gp)
				if gp then
					return
				end

				if props.OnInputEnded then
					props.OnInputEnded(input)
				end
			end or nil,
		})

		allCollectors:set(allCollectors:get() + 1)

		local function updateVisibility()
			if use(props.Visible) then
				-- we have to keep track of all collectors so that new collectors will always be placed below currently active ones
				table.insert(activeCollectors, component)
				zIndex:set(allCollectors:get(false) - #activeCollectors)
				layer:add(component)
			else
				table.remove(activeCollectors, table.find(activeCollectors, component))
				zIndex:set(-1)
				layer:remove(component)
			end
		end

		onDestroy(props.ReferenceObject, {
			Observer(props.Visible):onChange(updateVisibility),
			function()
				table.remove(activeCollectors, table.find(activeCollectors, component))
				allCollectors:set(allCollectors:get(false) - 1)
				zIndex:set(-1)
				layer:remove(component)
			end,
		})

		updateVisibility()
	end)
end

return inputCollector
