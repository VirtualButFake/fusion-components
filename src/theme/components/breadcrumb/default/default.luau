local tailwind = require("@packages/tailwind")

return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Text = themeName == "Dark" and tailwind.neutral[400] or tailwind.neutral[500],
		},
		Hover = {
			Text = themeName == "Dark" and tailwind.neutral[200] or tailwind.neutral[700],
		},
		Selected = {
			Text = themeName == "Dark" and primaryColor[400] or primaryColor[500],
		},
	}
end
