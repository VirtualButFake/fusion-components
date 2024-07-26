local tailwind = require("@packages/tailwind")

return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Background = { color = themeName == "Dark" and primaryColor[400] or primaryColor[500], shadow = 1 },
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
		},
		Hover = {
			Background = { color = primaryColor[450], shadow = 1 },
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
		},
		Pressing = {
			Background = { color = themeName == "Dark" and primaryColor[500] or primaryColor[400], shadow = 1 },
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
		},
		Disabled = {
			Background = {
				color = themeName == "Dark" and primaryColor[400] or primaryColor[500],
				transparency = 0.2,
			},
			Text = {
				color = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
				transparency = 0.2,
			},
		},
	}
end
