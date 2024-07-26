local tailwind = require("@packages/tailwind")

return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Background = { color = themeName == "Dark" and primaryColor[400] or primaryColor[500], shadow = 2 },
			Title = themeName == "Dark" and tailwind.neutral[900] or tailwind.white,
			Description = {
				color = themeName == "Dark" and tailwind.neutral[900] or tailwind.white,
				transparency = 0.25,
			},
		},
	}
end
