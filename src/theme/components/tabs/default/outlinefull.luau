local tailwind = require("@packages/tailwind")

return function(themeName: string, primaryColor: { Color3 })
	return {
		Container = {
			Background = { color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[50], shadow = 2 },
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[200],
		},
		Base = {
			Text = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
		},
		Hover = {
			Background = themeName == "Dark" and { color = primaryColor[700], transparency = 0.5 } or primaryColor[300],
			Text = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
			Stroke = themeName == "Dark" and primaryColor[400] or primaryColor[500],
		},
		Press = {
			Background = themeName == "Dark" and { color = primaryColor[700], transparency = 0.2 }
				or { color = primaryColor[400], transparency = 0.3 },
			Text = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
			Stroke = themeName == "Dark" and primaryColor[400] or primaryColor[500],
		},
		Active = {
			Background = { color = themeName == "Dark" and primaryColor[500] or primaryColor[400] },
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
			Stroke = themeName == "Dark" and primaryColor[500] or primaryColor[400],
		},
		Disabled = {
			Text = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
		},
		ActiveDisabled = {
			Background = {
				color = themeName == "Dark" and primaryColor[500] or primaryColor[400],
				transparency = 0.5,
			},
			Stroke = { color = themeName == "Dark" and primaryColor[400] or primaryColor[500], transparency = 0.7 },
			Text = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
		},
	}
end
