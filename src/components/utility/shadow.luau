-- Significant pieces of code taken from Lydie, found here:
-- https://github.com/7kayoh/Lydie/blob/main/src/Components/Shadow.luau, which in turn takes code from
-- https://github.com/AmaranthineCodices/roact-material/blob/master/src/Components/Shadow.lua
local fusion = require("@packages/fusion")
local Spring = fusion.Spring

local Children = fusion.Children
local Cleanup = fusion.Cleanup
local New = fusion.New
local Ref = fusion.Ref

local Clean = fusion.cleanup
local Computed = fusion.Computed
local ForValues = fusion.ForValues
local Observer = fusion.Observer
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use
local peek = fusionUtils.peek

local shadowData = {
	[0] = {
		Ambient = {
			Opacity = 0,
			Blur = 0,
		},

		Penumbra = {
			Opacity = 0,
			Blur = 0,
		},

		Umbra = {
			Opacity = 0,
			Blur = 0,
		},
	},
	[1] = {
		Ambient = {
			Opacity = 0.2,
			Blur = 3,
			Offset = UDim2.new(0, 0, 0, 1),
		},

		Penumbra = {
			Opacity = 0.12,
			Blur = 2,
			Offset = UDim2.new(0, 0, 0, 2),
		},

		Umbra = {
			Opacity = 0.14,
			Blur = 2,
		},
	},
	[2] = {
		Ambient = {
			Opacity = 0.2,
			Blur = 5,
			Offset = UDim2.new(0, 0, 0, 1),
		},

		Penumbra = {
			Opacity = 0.12,
			Blur = 4,
			Offset = UDim2.new(0, 0, 0, 3),
		},

		Umbra = {
			Opacity = 0.14,
			Blur = 4,
		},
	},
	[3] = {
		Ambient = {
			Opacity = 0.2,
			Blur = 8,
			Offset = UDim2.new(0, 0, 0, 1),
		},

		Penumbra = {
			Opacity = 0.12,
			Blur = 4,
			Offset = UDim2.new(0, 0, 0, 3),
		},

		Umbra = {
			Opacity = 0.14,
			Blur = 3,
			Offset = UDim2.new(0, 0, 0, 3),
		},
	},
	[4] = {
		Ambient = {
			Opacity = 0.2,
			Blur = 10,
			Offset = UDim2.new(0, 0, 0, 1),
		},

		Penumbra = {
			Opacity = 0.12,
			Blur = 5,
			Offset = UDim2.new(0, 0, 0, 4),
		},

		Umbra = {
			Opacity = 0.14,
			Blur = 4,
			Offset = UDim2.new(0, 0, 0, 2),
		},
	},
	[6] = {
		Ambient = {
			Opacity = 0.2,
			Blur = 5,
			Offset = UDim2.new(0, 0, 0, 3),
		},

		Penumbra = {
			Opacity = 0.12,
			Blur = 18,
			Offset = UDim2.new(0, 0, 0, 1),
		},

		Umbra = {
			Opacity = 0.14,
			Blur = 10,
			Offset = UDim2.new(0, 0, 0, 6),
		},
	},
	[8] = {
		Ambient = {
			Opacity = 0.2,
			Blur = 15,
			Offset = UDim2.new(0, 0, 0, 4),
		},

		Penumbra = {
			Opacity = 0.12,
			Blur = 14,
			Offset = UDim2.new(0, 0, 0, 3),
		},

		Umbra = {
			Opacity = 0.14,
			Blur = 10,
			Offset = UDim2.new(0, 0, 0, 8),
		},
	},
	[9] = {
		Ambient = {
			Opacity = 0.2,
			Blur = 6,
			Offset = UDim2.new(0, 0, 0, 5),
		},

		Penumbra = {
			Opacity = 0.12,
			Blur = 16,
			Offset = UDim2.new(0, 0, 0, 3),
		},

		Umbra = {
			Opacity = 0.14,
			Blur = 12,
			Offset = UDim2.new(0, 0, 0, 9),
		},
	},
	[12] = {
		Ambient = {
			Opacity = 0.2,
			Blur = 8,
			Offset = UDim2.new(0, 0, 0, 7),
		},

		Penumbra = {
			Opacity = 0.12,
			Blur = 22,
			Offset = UDim2.new(0, 0, 0, 5),
		},

		Umbra = {
			Opacity = 0.14,
			Blur = 17,
			Offset = UDim2.new(0, 0, 0, 12),
		},
	},
	[16] = {
		Ambient = {
			Opacity = 0.2,
			Blur = 10,
			Offset = UDim2.new(0, 0, 0, 8),
		},

		Penumbra = {
			Opacity = 0.12,
			Blur = 30,
			Offset = UDim2.new(0, 0, 0, 6),
		},

		Umbra = {
			Opacity = 0.14,
			Blur = 24,
			Offset = UDim2.new(0, 0, 0, 16),
		},
	},
}

for _, elevation in pairs(shadowData) do
	for _, data in pairs(elevation) do
		data.Size = UDim2.new(1, data.Blur, 1, data.Blur)
		data.Position = UDim2.new(0.5, 0, 0.5, 0) + (data.Offset or UDim2.new())
		data.ImageTransparency = 1 - data.Opacity

		data.Blur = nil
		data.Offset = nil
		data.Opacity = nil
	end
end

local function tableToReactiveTable(table: { [string]: any }): {
	[string]: fusion.Value<any>,
}?
	local reactiveTable = {}

	for key, value in pairs(table) do
		reactiveTable[key] = Value(value)
	end

	return reactiveTable
end

local function getShadowData(elevation: number): shadowData
	local data = shadowData[elevation]

	return {
		Penumbra = tableToReactiveTable(data.Penumbra),
		Umbra = tableToReactiveTable(data.Umbra),
		Ambient = tableToReactiveTable(data.Ambient),
	}
end

local function updateShadowData(data: shadowData, elevation: number)
	local newData = shadowData[elevation]

	for key, value in newData.Penumbra do
		data.Penumbra[key]:set(value)
	end

	for key, value in newData.Umbra do
		data.Umbra[key]:set(value)
	end

	for key, value in newData.Ambient do
		data.Ambient[key]:set(value)
	end
end

local function interpolate(a: number, b: number, t: number): number
	return a + (b - a) * t
end

type shadowValue = {
	Size: fusion.Value<UDim2>,
	Position: fusion.Value<UDim2>,
	ImageTransparency: fusion.Value<number>,
}

type shadowData = {
	Penumbra: shadowValue,
	Umbra: shadowValue,
	Ambient: shadowValue,
}

type props = {
	Elevation: fusion.CanBeState<number>,
	TargetSize: fusion.CanBeState<Vector2>,
	Transparency: fusion.Value<number>?,
}

local SHADOW_IMAGE = "rbxassetid://1316045217"

local function shadow(props: props)
	local shadowTransparency = props.Transparency or Value(0)
	local container: fusion.Value<Frame> = Value()

	-- i love optimizing for 5 instances in total
	local wasRendered = Value(false)
	local shouldRender = Computed(function()
		local result = use(props.Elevation) ~= nil

		if not result and not wasRendered:get() then
			return false
		end

		wasRendered:set(true)
		return true
	end)

	local data = getShadowData(peek(props.Elevation) or 0)
	local disconnect = typeof(props.Elevation) == "table"
		and Observer(props.Elevation):onChange(function()
			updateShadowData(data, use(props.Elevation) or 0) -- doing this so that instead of refreshing the shadow, we can respond to it and animate between the states
		end)

	local shadows = ForValues({ "Penumbra", "Umbra", "Ambient" }, function(value)
		if data == nil then
			return nil
		end

		local valueData: shadowValue = data[value]
		local imageTransparencySpring = Spring(valueData.ImageTransparency, 22, 1)

		return New("ImageLabel")({
			Name = value,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = SHADOW_IMAGE,
			ImageColor3 = Color3.new(0, 0, 0),
			ImageTransparency = Computed(function()
				return interpolate(imageTransparencySpring:get(), 1, shadowTransparency:get())
			end),
			Position = Spring(valueData.Position, 22, 1),
			ScaleType = Enum.ScaleType.Slice,
			Size = Spring(valueData.Size, 22, 1),
			SliceCenter = Rect.new(10, 10, 118, 118),
		})
	end, Clean)

	return Computed(function()
		if not shouldRender:get() then
			return
		end

		return New("Frame")({
			Name = "ShadowContainer",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = -4,
			[Cleanup] = { disconnect },
			[Ref] = container,
			[Children] = {
				shadows,
				New("UISizeConstraint")({
					MaxSize = Computed(function()
						local targetSize = use(props.TargetSize)

						if targetSize then
							-- the line below is necessary to prevent an annoying warning
							targetSize = Vector2.new(
								math.clamp(targetSize.X, 1, math.huge),
								math.clamp(targetSize.Y, 1, math.huge)
							)
							return targetSize
						end

						return Vector2.new(1, 1)
					end),
				}),
			},
		})
	end, Clean)
end

return shadow
