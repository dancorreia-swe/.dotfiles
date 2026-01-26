local wezterm = require("wezterm")
local theme = require("theme")
local utils = require("utils")

local M = {}

-- Process icon mappings (computed once at module load)
local process_icons = {
  ["nvim"] = { icon = wezterm.nerdfonts.custom_neovim, color = theme.process.editor },
  ["vim"] = { icon = wezterm.nerdfonts.custom_vim, color = theme.process.editor },
  ["node"] = { icon = wezterm.nerdfonts.md_nodejs, color = theme.process.runtime },
  ["python"] = { icon = wezterm.nerdfonts.dev_python, color = theme.process.python },
  ["python3"] = { icon = wezterm.nerdfonts.dev_python, color = theme.process.python },
  ["git"] = { icon = wezterm.nerdfonts.dev_git, color = theme.process.git },
  ["ssh"] = { icon = wezterm.nerdfonts.md_server_network, color = theme.process.ssh },
  ["tmux"] = { icon = wezterm.nerdfonts.md_server_network, color = theme.process.ssh },
  ["zsh"] = { icon = wezterm.nerdfonts.dev_terminal, color = theme.process.shell },
  ["fish"] = { icon = wezterm.nerdfonts.md_fish, color = theme.process.shell },
  ["bash"] = { icon = wezterm.nerdfonts.dev_terminal, color = theme.process.shell },
  ["elixir"] = { icon = wezterm.nerdfonts.dev_elixir, color = theme.process.elixir },
  ["iex"] = { icon = wezterm.nerdfonts.custom_elixir, color = theme.process.elixir },
  ["mix"] = { icon = wezterm.nerdfonts.custom_elixir, color = theme.process.elixir },
  ["beam.smp"] = { icon = wezterm.nerdfonts.custom_elixir, color = theme.process.elixir },
  ["erl"] = { icon = wezterm.nerdfonts.fa_erlang, color = theme.process.elixir },
}

-- Pre-computed icons
local ssh_icon = { icon = wezterm.nerdfonts.md_server_network, color = theme.process.ssh }
local fallback_active = { icon = wezterm.nerdfonts.md_ghost, color = theme.process.fallback }
local fallback_inactive = { icon = wezterm.nerdfonts.md_ghost_off_outline, color = theme.process.fallback_inactive }

local function get_process_icon(tab)
  local pane = tab.active_pane
  local process_name = utils.basename(pane.foreground_process_name)

  -- Check for known process
  local icon = process_icons[process_name]
  if icon then
    return icon
  end

  -- Check if SSH domain
  local domain = pane.domain_name
  if domain and domain:sub(1, 4) == "SSH:" then
    return ssh_icon
  end

  -- Fallback based on active state
  return tab.is_active and fallback_active or fallback_inactive
end

local function get_tab_title(tab_info)
  -- Use explicitly set tab title if available
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end

  -- Otherwise, get the current working directory basename
  local cwd_uri = tab_info.active_pane.current_working_dir
  if cwd_uri and cwd_uri.file_path then
    local basename = cwd_uri.file_path:match("([^/]+)/?$")
    if basename then
      return basename
    end
  end

  -- Fallback to pane title
  return tab_info.active_pane.title
end

function M.apply_to_config(config)
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

  wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
    local title = wezterm.truncate_right(get_tab_title(tab), max_width - 2)
    local process = get_process_icon(tab)

    if tab.is_active then
      return {
        { Background = { Color = theme.ui.active_tab_bg } },
        { Foreground = { Color = process.color } },
        { Text = "  " .. process.icon .. "   " },
        { Foreground = { Color = theme.ui.active_tab_fg } },
        { Text = title .. " " },
      }
    else
      return {
        { Background = { Color = "none" } },
        { Foreground = { Color = process.color } },
        { Text = "  " .. process.icon .. "   " },
        { Foreground = { Color = theme.ui.inactive_tab_fg } },
        { Text = title .. " " },
      }
    end
  end)
end

return M
