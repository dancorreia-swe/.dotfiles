local module = {}

function module.apply_to_config(config)
	config.window_decorations = "RESIZE"
	config.window_background_opacity = 0.8
	config.macos_window_background_blur = 15
end

return module
