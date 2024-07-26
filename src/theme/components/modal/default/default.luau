local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Background = {
				color = themeName == "Dark" and tailwind.neutral[800] or tailwind.neutral[200],
				transparency = 0.25,
			},
		},
	}
end
