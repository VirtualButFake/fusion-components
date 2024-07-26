local tailwind = require("@packages/tailwind")

return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Hover = {
			Background = { color = themeName == "Dark" and primaryColor[450] or primaryColor[450], transparency = 0.25 },
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Pressing = {
			Background = { color = themeName == "Dark" and primaryColor[450] or primaryColor[500], transparency = 0.5 },
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Selected = {
			Background = themeName == "Dark" and primaryColor[500] or primaryColor[400],
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		SelectedDisabled = {
			Background = {
				color = themeName == "Dark" and primaryColor[600] or primaryColor[300],
				transparency = 0.5,
			},
			Text = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
		},
		Disabled = {
			Text = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
		},
	}
end
