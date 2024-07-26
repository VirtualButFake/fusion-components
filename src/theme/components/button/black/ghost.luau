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
			Background = themeName == "Dark" and tailwind.neutral[300] or tailwind.neutral[700],
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.neutral[100],
		},
		Disabled = {
			Text = themeName == "Dark" and tailwind.neutral[300] or tailwind.neutral[700],
		},
	}
end
