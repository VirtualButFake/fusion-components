local tailwind = require("@packages/tailwind")

return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Placeholder = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
			Text = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
			Stroke = themeName == "Dark" and primaryColor[400] or primaryColor[500],
		},
		Hover = {
			Placeholder = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
			Text = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
			Stroke = themeName == "Dark" and primaryColor[450] or primaryColor[450],
		},
		Focus = {
			Placeholder = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
			Text = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
			Stroke = themeName == "Dark" and primaryColor[500] or primaryColor[400],
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
				color = themeName == "Dark" and primaryColor[400] or primaryColor[500],
				transparency = 0.25,
			},
		},
	}
end
