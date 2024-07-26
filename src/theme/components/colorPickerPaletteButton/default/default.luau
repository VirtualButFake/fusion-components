local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Background = {
				color = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
				transparency = 1,
				shadow = 2,
			},
		},
		Hover = {
			Background = {
				color = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
				transparency = 1,
			},
			Stroke = {
				color = themeName == "Dark" and tailwind.white or tailwind.neutral[600],
			},
		},
		Press = {
			Background = {
				color = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
				transparency = 0.8,
			},
			Stroke = {
				color = themeName == "Dark" and tailwind.neutral[400] or tailwind.neutral[500],
			},
		},
	}
end
