local tailwind = require("@packages/tailwind")

return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Background = { color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[200], shadow = 1 },
			Highlight = themeName == "Dark" and primaryColor[400] or primaryColor[500],
			Indicator = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
		},
	}
end
