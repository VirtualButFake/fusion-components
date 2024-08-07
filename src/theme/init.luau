local Studio = pcall(settings) and settings().Studio or nil

local themeFramework = require("@packages/themeFramework")
local tailwind = require("@packages/tailwind")
local fusion = require("@packages/fusion")
local Value = fusion.Value
local Clean = fusion.cleanup

export type color = themeFramework.color
export type colorTable = themeFramework.colorTable
export type optionalColorTable = themeFramework.optionalColorTable
export type useColorFunction = themeFramework.useColorFunction

local globals = {
	font = Value(Font.fromEnum(Enum.Font.SourceSans)),
	isDark = Value(false),
	background = Value(Color3.fromRGB(255, 255, 255)),
}

local function reloadTheme(self: themeFramework.themeFramework, themeName)
	local isDark = themeName == "Dark"
	local background = isDark and tailwind.neutral[900] or tailwind.neutral[100]

	globals.isDark:set(isDark)
	globals.background:set(background)

	self:setFallback(background)
end

local theme = themeFramework.new(script.components, reloadTheme)

local connections = {
	Studio and Studio.ThemeChanged:Connect(function()
		theme:load(theme:build(Studio.Theme.Name))
	end),
	script.Destroying:Connect(function()
		theme.destroy()
	end),
}

theme:load(theme:build(Studio and Studio.Theme.Name or "Dark"))

local wasDestroyed = false

return setmetatable({
	global = globals,
	destroy = function()
		if wasDestroyed then
			return
		end

		wasDestroyed = true

		Clean(theme, connections)
		theme = nil
	end,
	setFont = function(font: Font)
		globals.font:set(font)
	end,
	setTheme = function(themeName: string)
		theme:load(theme:build(themeName))
	end,
}, {
	__index = theme,
}) :: themeFramework.themeFramework & {
	destroy: () -> (),
	setFont: (font: Font) -> (),
	setTheme: (theme: string) -> (),
	global: {
		font: Font,
		isDark: fusion.Value<boolean>,
		background: fusion.Value<Color3>,
	},
}
