local tailwind = require("@packages/tailwind")

return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Background = { color = themeName == "Dark" and primaryColor[400] or primaryColor[500], shadow = 1 },
			Text = themeName == "Dark" and tailwind.neutral[900] or tailwind.white,
		},
	}
end
