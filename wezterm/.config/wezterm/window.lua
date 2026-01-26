local wezterm = require("wezterm")

local M = {}

function M.apply_to_config(config)
	-- Performance settings
	config.max_fps = 120
	config.animation_fps = 60
	config.scrollback_lines = 10000

	-- Window appearance
	config.window_decorations = "RESIZE"
	config.window_padding = {
		left = 16,
		right = 16,
		top = 16,
		bottom = 8,
	}

	wezterm.on("format-window-title", function(tab, pane, tabs, panes, cfg)
		local zoomed = tab.active_pane.is_zoomed and " " or ""
		local index = #tabs > 1 and string.format("(%d/%d) ", tab.tab_index + 1, #tabs) or ""
		return zoomed .. index .. tab.active_pane.title
	end)
end

return M
