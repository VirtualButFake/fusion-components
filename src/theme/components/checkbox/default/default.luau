local tailwind = require("@packages/tailwind")

return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Background = themeName == "Dark" and tailwind.neutral[850] or tailwind.white,
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
		},
		Hover = {
			Background = themeName == "Dark" and { color = tailwind.neutral[700], transparency = 0 }
				or tailwind.neutral[50],
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
		},
		Active = {
			Background = { color = themeName == "Dark" and primaryColor[400] or primaryColor[500], shadow = 2 },
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
		},
		HoverActive = {
			Background = { color = themeName == "Dark" and primaryColor[450] or primaryColor[450], shadow = 2 },
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
		},
		Disabled = {
			Background = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[200],
			Stroke = themeName == "Dark" and tailwind.neutral[600] or tailwind.neutral[300],
		},
		DisabledActive = {
			Background = { color = themeName == "Dark" and primaryColor[500] or primaryColor[400], transparency = 0.25 },
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
		},
	}
end
