local fusion = require("@packages/fusion")
local Computed = fusion.Computed

local fusionUtils = require("@packages/fusionUtils")
local use = fusionUtils.use

type props = {
	Loaded: fusion.StateObject<boolean>,
	TemporaryContent: fusion.CanBeState<{ any }>,
	Children: fusion.CanBeState<{ any }>,
}

local function await(props: props): fusion.Computed<{ any }>
	return Computed(function()
		return props.Loaded:get() and use(props.Children) or use(props.TemporaryContent)
	end)
end

return await
