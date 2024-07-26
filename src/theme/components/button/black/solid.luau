local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Background = { color = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900], shadow = 1 },
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
			Stroke = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
		},
		Hover = {
			Background = { color = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[800], shadow = 1 },
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
			Stroke = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
		},
		Pressing = {
			Background = { color = themeName == "Dark" and tailwind.neutral[300] or tailwind.neutral[700], shadow = 1 },
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
			Stroke = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
		},
		Disabled = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
				transparency = 0.25,
			},
			Text = {
				color = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
				transparency = 0.25,
			},
			Stroke = {
				color = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
				transparency = 0.25,
			},
		},
	}
end
