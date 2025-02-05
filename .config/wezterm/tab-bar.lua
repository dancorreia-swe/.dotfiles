local wezterm = require("wezterm")

local module = {}

function module.apply_to_config(config)
	config.tab_bar_at_bottom = true
	config.window_padding = {
		left = 8,
		right = 8,
		top = 8,
		bottom = 8,
	}
	config.use_fancy_tab_bar = true
	config.hide_tab_bar_if_only_one_tab = false
	config.show_new_tab_button_in_tab_bar = false
	config.tab_and_split_indices_are_zero_based = false

	config.window_frame = {
		inactive_titlebar_bg = "none",
		active_titlebar_bg = "none",
	}

	local LEFT_END = utf8.char(0xE0B6)
	local RIGHT_END = utf8.char(0xE0B4)

	local active_tab_bg_color = "#FFA066"
	local inactive_tab_text_color = "#526F76"
	local active_tab_fg_color = "#22222B" --'#051321' --'#15151A' --'#001C23'
	local inactive_tab_bg_color = "#22222B"

	local function tab_title(tab_info)
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
		local title = tab_title(tab)

		title = wezterm.truncate_right(title, max_width - 2)

		local main_bg_color = "#22222B"
		local background = "#22222B"
		local tab_icon_inactive = "#495267"
		local tab_icon_inactive_icon = wezterm.nerdfonts.md_ghost_off_outline
		local tab_icon_active_icon = wezterm.nerdfonts.md_ghost

		local icon_text = ""
		local tab_icon_color = ""
		local tab_text_color = ""
		local tab_background_color = ""

		if tab.is_active then
			tab_icon_color = active_tab_fg_color
			tab_text_color = active_tab_fg_color
			tab_background_color = active_tab_bg_color
			icon_text = tab_icon_active_icon
		else
			tab_icon_color = tab_icon_inactive
			tab_text_color = inactive_tab_text_color
			icon_text = tab_icon_inactive_icon
			tab_background_color = inactive_tab_bg_color
		end
		-- ensure that the titles fit in the available space,
		-- and that we have room for the edges.
		return {
			{ Background = { Color = main_bg_color } },
			{ Foreground = { Color = tab_background_color } },
			{ Text = LEFT_END },
			{ Background = { Color = tab_background_color } },
			{ Foreground = { Color = tab_icon_color } },
			{ Text = " " .. icon_text .. "  " },
			{ Background = { Color = tab_background_color } },
			{ Foreground = { Color = tab_text_color } },
			{ Text = title .. "  " },
			{ Background = { Color = background } },
			{ Foreground = { Color = tab_background_color } },
			{ Text = RIGHT_END },
		}
	end)
end

return module
