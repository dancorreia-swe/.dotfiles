local wezterm = require("wezterm")

local module = {}

function module.apply_to_config(config)
	config.front_end = "WebGpu"
	config.webgpu_power_preference = "HighPerformance"
	config.max_fps = 144
	config.animation_fps = 30
	config.window_decorations = "RESIZE"
	config.window_background_opacity = 0.90
	config.macos_window_background_blur = 15
	config.window_padding = {
		left = 16,
		right = 16,
		top = 16,
		bottom = 8,
	}

	wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
		local zoomed = ""
		if tab.active_pane.is_zoomed then
			zoomed = " "
		end

		local index = ""
		if #tabs > 1 then
			index = string.format("(%d/%d) ", tab.tab_index + 1, #tabs)
		end

		return zoomed .. index .. tab.active_pane.title
	end)
end

return module
