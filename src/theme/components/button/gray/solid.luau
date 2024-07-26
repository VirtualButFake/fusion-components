local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Background = { color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[50], shadow = 1 },
			Text = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[200],
		},
		Hover = {
			Background = { color = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[100], shadow = 1 },
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[200],
		},
		Pressing = {
			Background = { color = themeName == "Dark" and tailwind.neutral[650] or tailwind.neutral[150], shadow = 1 },
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[200],
		},
		Disabled = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[50],
				transparency = 0.4,
			},
			Text = {
				color = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
				transparency = 0.4,
			},
			Stroke = {
				color = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[200],
				transparency = 0.4,
			},
		},
	}
end
