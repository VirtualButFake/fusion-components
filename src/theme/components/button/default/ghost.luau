return function(themeName: string, primaryColor: { Color3 })
	return {
		Base = {
			Text = themeName == "Dark" and primaryColor[400] or primaryColor[500],
		},
		Hover = {
			Background = { color = themeName == "Dark" and primaryColor[900] or primaryColor[200], transparency = 0.45 },
			Text = themeName == "Dark" and primaryColor[400] or primaryColor[500],
		},
		Pressing = {
			Background = { color = themeName == "Dark" and primaryColor[850] or primaryColor[300], transparency = 0.45 },
			Text = themeName == "Dark" and primaryColor[400] or primaryColor[500],
		},
		Disabled = {
			Text = themeName == "Dark" and primaryColor[300] or primaryColor[600],
		},
	}
end
