local tailwind = require("@packages/tailwind")

return function(themeName: string)
	return {
		Base = {
			Background = themeName == "Dark" and tailwind.neutral[850] or tailwind.white,
			Stroke = themeName == "Dark" and tailwind.neutral[700] or tailwind.neutral[300],
			Text = themeName == "Dark" and tailwind.white or tailwind.neutral[900],
			Shadow = {
				shadow = 2,
			}, -- exists so we can make the canvasframe get it's own shadow
		},
	}
end
