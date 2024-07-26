local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			PaletteBackground = { color = themeName == "Dark" and tailwind.neutral[800] or tailwind.white, shadow = 2 },
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
			SliderHandle = {
				color = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[100],
				shadow = 2,
			},
		},
	}
end
