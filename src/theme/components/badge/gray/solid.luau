local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Background = { color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[50], shadow = 1 },
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
			Text = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
		},
	}
end
