local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Hover = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[100],
				transparency = themeName == "Dark" and 0.5 or 0,
			},
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Pressing = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[200],
				transparency = themeName == "Dark" and 0.25 or 0,
			},
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Selected = {
			Background = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[100],
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		SelectedDisabled = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
				transparency = 0.25,
			},
			Text = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
		},
		Disabled = {
			Text = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
		},
	}
end
