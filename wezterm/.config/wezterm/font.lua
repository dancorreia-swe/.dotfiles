local wezterm = require("wezterm")

local module = {}

function module.apply_to_config(config)
	config.font = wezterm.font_with_fallback({
		"JetBrainsMono Nerd Font",
		"SF Mono",
		"SF Pro",
	})
	config.font_size = 14
	config.cell_width = 0.9
	config.freetype_load_flags = "NO_HINTING"
	config.front_end = "OpenGL"
end

return module
