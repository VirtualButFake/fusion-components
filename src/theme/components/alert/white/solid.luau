local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Background = { color = themeName == "Dark" and tailwind.neutral[900] or tailwind.white, shadow = 2 },
			Stroke = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[200],
			Title = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
			Description = {
				color = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
				transparency = 0.25,
			},
		},
	}
end
