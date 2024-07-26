local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Background = { color = themeName == "Dark" and tailwind.neutral[850] or tailwind.white, shadow = 1 },
			Text = themeName == "Dark" and tailwind.neutral[50] or tailwind.neutral[900],
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
		},
		Hover = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[50],
				shadow = 1,
			},
			Text = themeName == "Dark" and tailwind.neutral[50] or tailwind.neutral[900],
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
		},
		Pressing = {
			Background = { color = themeName == "Dark" and tailwind.neutral[790] or tailwind.neutral[100], shadow = 1 },
			Text = themeName == "Dark" and tailwind.neutral[50] or tailwind.neutral[900],
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
		},
		Disabled = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[850] or tailwind.white,
				transparency = 0.25,
			},
			Text = {
				color = themeName == "Dark" and tailwind.neutral[50] or tailwind.neutral[900],
				transparency = 0.25,
			},
			Stroke = {
				color = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
				transparency = 0.25,
			},
		},
	}
end
