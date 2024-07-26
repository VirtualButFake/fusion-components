local tailwind = require("@packages/tailwind")

return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Background = { color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[200], shadow = 1 },
			Highlight = themeName == "Dark" and primaryColor[400] or primaryColor[500],
			Handle = { color = themeName == "Dark" and primaryColor[400] or primaryColor[500], shadow = 1 },
			Step = themeName == "Dark" and tailwind.neutral[750] or tailwind.neutral[350],
		},
		Hover = {
			Background = { color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[200], shadow = 1 },
			Highlight = primaryColor[450],
			Handle = { color = themeName == "Dark" and primaryColor[450] or primaryColor[450], shadow = 1 },
			Step = themeName == "Dark" and tailwind.neutral[750] or tailwind.neutral[350],
		},
	}
end
