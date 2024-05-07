local wezterm = require("wezterm")

local module = {}

function module.apply_to_config(config)
	config.font = wezterm.font_with_fallback({ "JetBrainsMono Nerd Font", "SF Mono" })
	config.font_size = 15
	config.cell_width = 0.9
	config.freetype_load_flags = "NO_HINTING"
end

return module
