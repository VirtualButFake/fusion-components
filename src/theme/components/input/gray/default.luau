local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Placeholder = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
			Text = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
			Background = { color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[50], shadow = 2 },
		},
		Hover = {
			Placeholder = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
			Text = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
			Stroke = themeName == "Dark" and tailwind.neutral[600] or tailwind.neutral[400],
			Background = { color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[50], shadow = 2 },
		},
		Focus = {
			Placeholder = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
			Text = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
			Stroke = themeName == "Dark" and tailwind.neutral[550] or tailwind.neutral[450],
			Background = { color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[50], shadow = 4 },
		},
		Disabled = {
			Placeholder = {
				color = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
				transparency = 0.25,
			},
			Text = {
				color = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
				transparency = 0.25,
			},
			Stroke = {
				color = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
				transparency = 0.25,
			},
			Background = {
				color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[50],
				transparency = 0.25,
			},
		},
	}
end
