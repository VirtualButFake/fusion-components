local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[50],
				transparency = themeName == "Dark" and 0.75 or 0.25,
			},
			Title = themeName == "Dark" and tailwind.neutral[300] or tailwind.neutral[700],
			Description = {
				color = themeName == "Dark" and tailwind.neutral[300] or tailwind.neutral[700],
				transparency = 0.25,
			},
		},
	}
end
