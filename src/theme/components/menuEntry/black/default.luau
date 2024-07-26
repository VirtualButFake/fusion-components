local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Hover = {
			Background = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[800],
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
		},
		Pressing = {
			Background = themeName == "Dark" and { color = tailwind.neutral[300], transparency = 0.25 }
				or tailwind.neutral[700],
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
		},
		Selected = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[800],
				transparency = 0.05,
			},
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
		},
		SelectedDisabled = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[800],
				transparency = 0.5,
			},
			Text = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[200],
		},
		Disabled = {
			Text = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
		},
	}
end
