local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
	config.font = wezterm.font_with_fallback({
		"JetBrainsMono Nerd Font",
		"SF Mono",
		"SF Pro",
	})
	config.font_size = 16
	config.cell_width = 0.9

	-- Font rendering
	config.freetype_load_flags = "NO_HINTING"
	config.front_end = "OpenGL"
	config.webgpu_power_preference = "HighPerformance"

	-- Uncomment to disable ligatures for better performance
	-- config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
end

return M
