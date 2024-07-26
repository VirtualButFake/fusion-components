return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Stroke = themeName == "Dark" and primaryColor[400] or primaryColor[500],
			Text = themeName == "Dark" and primaryColor[400] or primaryColor[500],
		},
	}
end
