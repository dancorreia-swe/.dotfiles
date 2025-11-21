local module = {}

function module.apply_to_config(config)
	config.front_end = "WebGpu"
	config.max_fps = 144
	config.animation_fps = 30
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
