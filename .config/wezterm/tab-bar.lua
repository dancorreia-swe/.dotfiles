local wezterm = require("wezterm")

local module = {}

function module.apply_to_config(config)
	-- Tab bar
	config.hide_tab_bar_if_only_one_tab = false
	config.enable_tab_bar = true
	config.tab_bar_at_bottom = true
	config.window_padding = {
		left = 16,
		right = 16,
		top = 16,
		bottom = 16,
	}
	config.use_fancy_tab_bar = false

	local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

	-- This function returns the suggested title for a tab.
	-- It prefers the title that was set via `tab:set_title()`
	-- or `wezterm cli set-tab-title`, but falls back to the
	-- title of the active pane in that tab.
	function tab_title(tab_info)
		local title = tab_info.tab_title
		-- if the tab title is explicitly set, take that
		if title and #title > 0 then
			return title
		end
		-- Otherwise, use the title from the active pane
		-- in that tab
		return tab_info.active_pane.title
	end

	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		local edge_background = "rgba(0, 0, 0, 0.2)"
		local background = "#1E1E24"
		local foreground = "#808080"

		if tab.is_active then
			background = "#323238"
			foreground = "#c0c0c0"
		elseif hover then
			background = "#3c3a39"
			foreground = "#909090"
		end

		local edge_foreground = background

		local title = tab_title(tab)

		-- ensure that the titles fit in the available space,
		-- and that we have room for the edges.
		title = wezterm.truncate_right(title, max_width - 2)

		if tab.tab_index == #tabs - 1 then
			return {
				{ Background = { Color = edge_background } },
				{ Foreground = { Color = edge_foreground } },
				{ Background = { Color = background } },
				{ Foreground = { Color = foreground } },
				{ Text = " " .. title .. " " },
				{ Background = { Color = edge_background } },
				{ Foreground = { Color = edge_foreground } },
				{ Text = SOLID_RIGHT_ARROW },
			}
		end

		return {
			{ Background = { Color = edge_background } },
			{ Foreground = { Color = edge_foreground } },
			-- { Text = " " .. title },
			{ Background = { Color = background } },
			{ Foreground = { Color = foreground } },
			{ Text = " " .. title .. " " },
			-- { Background = { Color = edge_background } },
			-- { Foreground = { Color = edge_foreground } },
			-- { Text = SOLID_RIGHT_ARROW },
		}
	end)

	config.show_new_tab_button_in_tab_bar = false
end

return module
