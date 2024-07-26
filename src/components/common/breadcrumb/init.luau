local fusion = require("@packages/fusion")
local Tween = fusion.Tween

local Children = fusion.Children
local Hydrate = fusion.Hydrate
local New = fusion.New

local Clean = fusion.cleanup
local Computed = fusion.Computed
local ForPairs = fusion.ForPairs
local Value = fusion.Value

local fusionUtils = require("@packages/fusionUtils")
local peek = fusionUtils.peek
local use = fusionUtils.use
local propertyProvider = fusionUtils.propertyProvider

local theme = require("@src/theme")

local breadcrumbLabel = require("./label")

local baseIcon = require("@components/base/icon")

local canvasFrame = require("@components/utility/canvasFrame")

type props = {
	Color: fusion.CanBeState<string>,
	AppearanceOverride: fusion.CanBeState<theme.optionalColorTable>?,
	Labels: fusion.CanBeState<{ breadcrumbLabel.label }>,
	Divider: fusion.CanBeState<string | Instance>?,
	[any]: any,
}

local function breadcrumb(props: props): Frame
	local useColor = theme:get("breadcrumb", props.Color, "default", "Base", props.AppearanceOverride)
	-- An annoying issue was popping up where the latest label would not be highlighted
	-- I'm still not sure what caused this, but this fixed it
	-- It's probably weird dependency stuff because using peek() fixed the issue entirely
	local labelCount = Value(0)
	local knownLabels: {
		[number]: {
			Instance: Instance,
			Transparency: fusion.Value<number>,
		},
	} = {}

	local overwroteValue: typeof(knownLabels) = {}

	local component = New("Frame")({
		Name = "Breadcrumb",
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		[Children] = {
			New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			ForPairs(props.Labels, function(index, label: breadcrumbLabel.label)
				labelCount:set(peek(labelCount) + 1)
				local Transparency = Value(1)

				local canvas = canvasFrame({
					GroupTransparency = Tween(
						Transparency,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
					),
					Children = {
						New("UIListLayout")({
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0, 2),
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}),
						Computed(function()
							if index == 1 then
								return nil
							end

							local divider = props.Divider or "chevron-right"

							if typeof(divider) == "Instance" then
								return divider
							end

							return baseIcon({
								Icon = {
									Name = use(divider),
									Size = 16,
								},
								Color = useColor("Text", true),
							})
						end, Clean) :: any,
						breadcrumbLabel({
							Name = "BreadcrumbLabel",
							Color = props.Color,
							AppearanceOverride = props.AppearanceOverride,
							Label = label,
							Selected = Computed(function()
								return index == use(labelCount)
							end),
						}),
					},
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					LayoutOrder = index,
				})

				if knownLabels[index] then
					knownLabels[index].Transparency:set(1)
					overwroteValue[index] = knownLabels[index]
				end

				knownLabels[index] = {
					Instance = canvas,
					Transparency = Transparency,
				}

				Transparency:set(0)

				return index, canvas, { TransparencyValue = Transparency }
			end, function(index: number, _, meta: any)
				-- so we know that earlier indices are processed first. using this knowledge, we can fade out the labels together
				local pendingDestruction = {}
				local foundSelf = false

				for i = index, #knownLabels do
					local value = knownLabels[i]

					if i == index then
						if meta.TransparencyValue ~= knownLabels[i].Transparency then
							if overwroteValue[i] == nil then
								continue
							end

							if overwroteValue[i].Transparency ~= meta.TransparencyValue then
								continue
							end

							value = overwroteValue[i]
							overwroteValue[i] = nil
						else
							knownLabels[i] = nil
						end

						foundSelf = true
					else
						knownLabels[i] = nil
					end

					value.Transparency:set(1)
					table.insert(pendingDestruction, value.Instance)
				end

				labelCount:set(labelCount:get() - 1)

				if foundSelf then -- issue: this doesn't get hit when something is NOT overwritten
					task.wait(0.15)
				end

				Clean(index, meta, pendingDestruction)
			end) :: any,
		},
	})

	return Hydrate(component)(propertyProvider.getPropsAndSpecialKeys(props, "Frame")) :: Frame
end

return breadcrumb
