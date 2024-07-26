return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Text = themeName == "Dark" and primaryColor[400] or primaryColor[500],
			Stroke = themeName == "Dark" and primaryColor[400] or primaryColor[500],
		},
		Hover = {
			Text = themeName == "Dark" and primaryColor[500] or primaryColor[400],
			Stroke = themeName == "Dark" and primaryColor[500] or primaryColor[400],
		},
		Pressing = {
			Text = themeName == "Dark" and primaryColor[600] or primaryColor[300],
			Stroke = themeName == "Dark" and primaryColor[600] or primaryColor[300],
		},
		Disabled = {
			Text = themeName == "Dark" and primaryColor[400] or primaryColor[500],
			Stroke = themeName == "Dark" and primaryColor[400] or primaryColor[500],
		},
	}
end
