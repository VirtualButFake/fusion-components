return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Background = themeName == "Dark" and { color = primaryColor[400], transparency = 0.9 } or primaryColor[50],
			Text = themeName == "Dark" and primaryColor[400] or primaryColor[500],
			Stroke = {
				color = themeName == "Dark" and primaryColor[400] or primaryColor[500],
				transparency = 0.75,
			},
		},
	}
end
