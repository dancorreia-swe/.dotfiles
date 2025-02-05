local module = {}

function module.apply_to_config(config)
	config.window_decorations = "RESIZE"
	config.window_background_opacity = 0.92
	config.macos_window_background_blur = 15
	config.window_padding = {
		left = 16,
		right = 16,
		top = 16,
		bottom = 8,
	}
end

return module
