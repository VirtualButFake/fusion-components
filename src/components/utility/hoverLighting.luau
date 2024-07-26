local fusion = require("@packages/fusion")
local Spring = fusion.Spring
local Tween = fusion.Tween

local Children = fusion.Children
local Cleanup = fusion.Cleanup
local New = fusion.New
local Out = fusion.Out

local Clean = fusion.cleanup
local Computed = fusion.Computed
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use

local theme = require("@src/theme")

local function interpolate(a: number, b: number, t: number): number
	return a + (b - a) * t
end

type props = {
	Component: fusion.CanBeState<Instance>,
	Hovering: fusion.CanBeState<boolean>,
	Position: fusion.CanBeState<Vector2>,
	CornerRadius: fusion.CanBeState<number>,
}

local function hoverLighting(props: props): ImageLabel
	return Computed(function()
		local absoluteSize = Value()
		local absolutePosition = Value()
		local uiInstance = use(props.Component)

		if uiInstance == nil then
			return nil
		end

		local uiTransparency = Value(uiInstance.BackgroundTransparency)

		local disconnect = uiInstance:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
			uiTransparency:set(uiInstance.BackgroundTransparency)
		end)

		return New("ImageLabel")({
			Name = "HoverLighting",
			BackgroundTransparency = 1,
			Image = "rbxassetid://17089662006",
			ImageColor3 = Computed(function()
				return use(theme.global.isDark) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
			end),
			ImageRectOffset = Spring(
				Computed(function()
					if absolutePosition:get() == nil or absoluteSize:get() == nil then
						return Vector2.new()
					end

					if absoluteSize:get() == Vector2.new() then
						return Vector2.new()
					end

					local largestSize = math.max(absoluteSize:get().X, absoluteSize:get().Y)
					local maxSize = math.clamp(largestSize * 2, 152, 256)
					local centerPosition = 512 - maxSize / 2

					local center = Vector2.new(centerPosition, centerPosition)
					local positionDifference = use(props.Position) - absolutePosition:get() - absoluteSize:get() / 2
					local scaleDifference = positionDifference / Vector2.new(largestSize, largestSize)

					return center - scaleDifference * maxSize
				end),
				25,
				1
			),
			ImageRectSize = Computed(function()
				if absoluteSize:get() == nil then
					return Vector2.new()
				end

				local largestSize = math.max(absoluteSize:get().X, absoluteSize:get().Y)
				local maxSize = math.clamp(largestSize * 2, 152, 256)
				return Vector2.new(maxSize, maxSize)
			end),
			ImageTransparency = Tween(
				Computed(function()
					local currentTransparency = uiTransparency:get() or 1
					local baseTransparency = currentTransparency
					local goalTransparency = use(props.Hovering) and 0.9 or 1

					return baseTransparency ~= 1 and interpolate(goalTransparency, 1, baseTransparency) or 1
				end),
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
			),
			ScaleType = Enum.ScaleType.Crop,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = -1,
			[Out("AbsolutePosition")] = absolutePosition,
			[Out("AbsoluteSize")] = absoluteSize,
			[Cleanup] = {
				disconnect,
			},
			[Children] = {
				New("UICorner")({
					CornerRadius = UDim.new(0, use(props.CornerRadius)) or UDim.new(0, 4),
				}),
			},
		})
	end, Clean)
end

return hoverLighting
