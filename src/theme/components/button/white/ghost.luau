local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Hover = {
			Background = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[200],
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Pressing = {
			Background = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Disabled = {
			Text = themeName == "Dark" and tailwind.neutral[400] or tailwind.neutral[500],
		},
	}
end
