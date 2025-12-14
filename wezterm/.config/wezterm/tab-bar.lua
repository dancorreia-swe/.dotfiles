local wezterm = require("wezterm")

local module = {}

-- Process icon mappings - customize these to your liking!
local process_icons = {
	["nvim"] = { icon = wezterm.nerdfonts.custom_neovim, color = "#89b4fa" },
	["vim"] = { icon = wezterm.nerdfonts.custom_vim, color = "#89b4fa" },
	["node"] = { icon = wezterm.nerdfonts.md_nodejs, color = "#a6e3a1" },
	["python"] = { icon = wezterm.nerdfonts.dev_python, color = "#f9e2af" },
	["python3"] = { icon = wezterm.nerdfonts.dev_python, color = "#f9e2af" },
	["git"] = { icon = wezterm.nerdfonts.dev_git, color = "#fab387" },
	["ssh"] = { icon = wezterm.nerdfonts.md_server_network, color = "#94e2d5" },
	["tmux"] = { icon = wezterm.nerdfonts.md_server_network, color = "#94e2d5" },
	["zsh"] = { icon = wezterm.nerdfonts.dev_terminal, color = "#b4befe" },
	["fish"] = { icon = wezterm.nerdfonts.md_fish, color = "#b4befe" },
	["elixir"] = { icon = wezterm.nerdfonts.dev_elixir, color = "#cba6f7" },
	["iex"] = { icon = wezterm.nerdfonts.custom_elixir, color = "#cba6f7" },
	["mix"] = { icon = wezterm.nerdfonts.custom_elixir, color = "#cba6f7" },
	["beam.smp"] = { icon = wezterm.nerdfonts.custom_elixir, color = "#cba6f7" },
	["erl"] = { icon = wezterm.nerdfonts.fa_erlang, color = "#cba6f7" },
	["bash"] = { icon = wezterm.nerdfonts.dev_terminal, color = "#b4befe" },
}

-- SSH icon for remote connections
local ssh_icon = { icon = wezterm.nerdfonts.md_server_network, color = "#94e2d5" }

-- Fallback ghost icons
local fallback_icon = {
	active = { icon = wezterm.nerdfonts.md_ghost, color = "#cdd6f4" },
	inactive = { icon = wezterm.nerdfonts.md_ghost_off_outline, color = "#45475a" },
}

local function get_process_icon(tab)
	local pane = tab.active_pane
	local process_name = pane.foreground_process_name
	-- Extract just the process name (remove path)
	process_name = process_name:gsub(".*[/\\]", "")

	-- Check if we're in an SSH domain (domain name starts with "SSH:")
	local domain = pane.domain_name or ""
	local is_ssh = domain:find("^SSH:") ~= nil

	-- If SSH domain, check for remote process first, then fall back to SSH icon
	if is_ssh then
		if process_icons[process_name] then
			return process_icons[process_name]
		end
		return ssh_icon
	end

	if process_icons[process_name] then
		return process_icons[process_name]
	end

	-- Return fallback based on active state
	if tab.is_active then
		return fallback_icon.active
	else
		return fallback_icon.inactive
	end
end

function module.apply_to_config(config)
	config.tab_bar_at_bottom = true
	config.use_fancy_tab_bar = true
	config.hide_tab_bar_if_only_one_tab = false
	config.show_new_tab_button_in_tab_bar = false
	config.show_close_tab_button_in_tabs = false
	config.tab_and_split_indices_are_zero_based = false

	config.window_frame = {
		inactive_titlebar_bg = "none",
		active_titlebar_bg = "none",
	}

	local active_tab_bg_color = "#313244" -- Surface0
	local inactive_tab_text_color = "#585b70"
	local active_tab_fg_color = "#cdd6f4" -- Text

	local function tab_title(tab_info)
		-- Use explicitly set tab title if available
		local title = tab_info.tab_title
		if title and #title > 0 then
			return title
		end

		-- Otherwise, get the current working directory basename
		local cwd_uri = tab_info.active_pane.current_working_dir
		if cwd_uri then
			local cwd = cwd_uri.file_path
			-- Extract basename (last component of path)
			local basename = cwd:match("([^/]+)/?$")
			if basename then
				return basename
			end
		end

		-- Fallback to pane title
		return tab_info.active_pane.title
	end

	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		local title = tab_title(tab)
		title = wezterm.truncate_right(title, max_width - 2)

		local process = get_process_icon(tab)
		local main_bg_color = "none"

		if tab.is_active then
			return {
				{ Background = { Color = active_tab_bg_color } },
				{ Foreground = { Color = process.color } },
				{ Text = "  " .. process.icon .. "   " },
				{ Foreground = { Color = active_tab_fg_color } },
				{ Text = title .. " " },
			}
		else
			return {
				{ Background = { Color = main_bg_color } },
				{ Foreground = { Color = process.color } },
				{ Text = "  " .. process.icon .. "   " },
				{ Foreground = { Color = inactive_tab_text_color } },
				{ Text = title .. " " },
			}
		end
	end)
end

return module
