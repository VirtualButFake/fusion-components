local tailwind = require("@packages/tailwind")

return function(themeName: string, primaryColor: { Color3 })
	return {
		Container = {
			Background = { color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[50], shadow = 1 },
		},
		Base = {
			Text = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
		},
		Hover = {
			Background = {
				color = themeName == "Dark" and primaryColor[700] or primaryColor[300],
				transparency = themeName == "Dark" and 0.5 or 0,
			},
			Text = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
		},
		Press = {
			Background = themeName == "Dark" and { color = primaryColor[700], transparency = 0.2 }
				or { color = primaryColor[400], transparency = 0.3 },
			Text = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
		},
		Active = {
			Background = { color = themeName == "Dark" and primaryColor[500] or primaryColor[400] },
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
		},
		Disabled = {
			Text = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
		},
		ActiveDisabled = {
			Background = {
				color = themeName == "Dark" and primaryColor[500] or primaryColor[400],
				transparency = 0.5,
			},
			Text = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
		},
	}
end
