local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Container = {},
		Base = {
			Text = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
		},
		Hover = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[200],
				transparency = 0.5,
			},
			Text = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
		},
		Press = {
			Background = themeName == "Dark" and { color = tailwind.neutral[800], transparency = 0.5 }
				or { color = tailwind.neutral[200], transparency = 0.1 },
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[700],
		},
		Active = {
			Background = themeName == "Dark" and tailwind.neutral[850] or tailwind.white,
			Text = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
		},
		Disabled = {
			Text = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
		},
		ActiveDisabled = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
				transparency = 0.5,
			},
			Text = themeName == "Dark" and tailwind.neutral[500] or tailwind.neutral[400],
		},
	}
end
