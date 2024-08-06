-- this can NOT be good practice, but it's the only way I could get this to work properly w/ wally

-- Base components
local baseIcon = require("@components/base/icon")
local baseButton = require("@components/base/button")
local baseFrame = require("@components/base/frame")
local baseImageLabel = require("@components/base/imageLabel")
local baseSinkFrame = require("@components/base/sinkFrame")
local baseText = require("@components/base/text")
local baseTextBox = require("@components/base/textBox")

-- Common components
local commonBreadcrumb = require("@components/common/breadcrumb")
local commonContextMenu = require("@components/common/contextMenu")
local commonMeter = require("@components/common/meter")
local commonTabs = require("@components/common/tabs")
local commonAlert = require("@components/common/alert")
local commonBadge = require("@components/common/badge")
local commonButton = require("@components/common/button")
local commonCheckbox = require("@components/common/checkbox")
local commonColorPicker = require("@components/common/colorPicker")
local commonInput = require("@components/common/input")
local commonInputMenu = require("@components/common/inputMenu")
local commonModal = require("@components/common/modal")
local commonPopover = require("@components/common/popover")
local commonProgressBar = require("@components/common/progressBar")
local commonRange = require("@components/common/range")
local commonSelectMenu = require("@components/common/selectMenu")
local commonSkeleton = require("@components/common/skeleton")
local commonSlider = require("@components/common/slider")
local commonTooltip = require("@components/common/tooltip")
local commonScrollingFrame = require("@components/common/scrollingFrame")

-- Utility components
local utilityAwait = require("@components/utility/await")
local utilityCanvasFrame = require("@components/utility/canvasFrame")
local utilityHoverLighting = require("@components/utility/hoverLighting")
local utilityInputCollector = require("@components/utility/inputCollector")
local utilityMenuEntry = require("@components/utility/menuEntry")
local utilityPlacementPopover = require("@components/utility/placementPopover")
local utilityPopover = require("@components/utility/popover")
local utilityShadow = require("@components/utility/shadow")
local utilityStoryBase = require("@components/utility/storyBase")

local index = {
	base = {
		icon = baseIcon,
		button = baseButton,
		frame = baseFrame,
		imageLabel = baseImageLabel,
		sinkFrame = baseSinkFrame,
		text = baseText,
		textBox = baseTextBox,
	},
	common = {
		breadcrumb = commonBreadcrumb,
		contextMenu = commonContextMenu,
		meter = commonMeter,
		tabs = commonTabs,
		alert = commonAlert,
		badge = commonBadge,
		button = commonButton,
		checkbox = commonCheckbox,
		colorPicker = commonColorPicker,
		input = commonInput,
		inputMenu = commonInputMenu,
		modal = commonModal,
		popover = commonPopover,
		progressBar = commonProgressBar,
		range = commonRange,
		selectMenu = commonSelectMenu,
		skeleton = commonSkeleton,
		slider = commonSlider,
		tooltip = commonTooltip,
		scrollingFrame = commonScrollingFrame,
	},
	utility = {
		await = utilityAwait,
		canvasFrame = utilityCanvasFrame,
		hoverLighting = utilityHoverLighting,
		inputCollector = utilityInputCollector,
		menuEntry = utilityMenuEntry,
		placementPopover = utilityPlacementPopover,
		popover = utilityPopover,
		shadow = utilityShadow,
		storyBase = utilityStoryBase,
	},
	theme = require("@src/theme"),
}

return index
