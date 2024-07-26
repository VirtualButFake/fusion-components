return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Background = {
				color = themeName == "Dark" and primaryColor[400] or primaryColor[250],
				transparency = 0.75,
			},
			Title = themeName == "Dark" and primaryColor[400] or primaryColor[500],
			Description = {
				color = themeName == "Dark" and primaryColor[400] or primaryColor[500],
				transparency = 0.25,
			},
		},
	}
end
