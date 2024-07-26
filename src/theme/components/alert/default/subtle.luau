return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Background = {
				color = themeName == "Dark" and primaryColor[400] or primaryColor[250],
				transparency = themeName == "Dark" and 0.75 or 0.75,
			},
			Stroke = { color = themeName == "Dark" and primaryColor[400] or primaryColor[500], transparency = 0.5 },
			Title = themeName == "Dark" and primaryColor[400] or primaryColor[500],
			Description = {
				color = themeName == "Dark" and primaryColor[400] or primaryColor[500],
				transparency = 0.25,
			},
		},
	}
end
