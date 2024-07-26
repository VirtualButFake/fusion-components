return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Stroke = themeName == "Dark" and primaryColor[400] or primaryColor[500],
			Title = themeName == "Dark" and primaryColor[400] or primaryColor[500],
			Description = {
				color = themeName == "Dark" and primaryColor[400] or primaryColor[500],
				transparency = 0.25,
			},
		},
	}
end
