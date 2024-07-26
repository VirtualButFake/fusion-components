local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Hover = {
			Background = themeName == "Dark" and tailwind.neutral[600] or tailwind.neutral[400],
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Pressing = {
			Background = tailwind.neutral[500],
			Text = themeName == "Dark" and tailwind.neutral[100] or tailwind.neutral[900],
		},
		Disabled = {
			Text = themeName == "Dark" and tailwind.neutral[400] or tailwind.neutral[500],
		},
	}
end
