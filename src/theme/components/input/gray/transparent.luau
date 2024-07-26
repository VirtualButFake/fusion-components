local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Placeholder = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
			Text = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
		},
		Hover = {
			Placeholder = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
			Text = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
		},
		Focus = {
			Placeholder = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
			Text = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
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
		},
	}
end
