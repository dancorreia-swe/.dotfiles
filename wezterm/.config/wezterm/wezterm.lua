local wezterm = require("wezterm")
local utils = require("utils")

-- Load plugins once at module level (cached by Lua)
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- Load config modules
local theme = require("theme")
local font = require("font")
local cursor = require("cursor")
local window = require("window")
local tab_bar = require("tab-bar")
local keybinds = require("keybinds")
local status_bar = require("status-bar")
local resurrect_config = require("resurrect")

local config = wezterm.config_builder()

-- Apply all config modules
font.apply_to_config(config)
window.apply_to_config(config)
cursor.apply_to_config(config)
tab_bar.apply_to_config(config)
status_bar.apply_to_config(config)
keybinds.apply_to_config(config)
theme.apply_to_config(config)
resurrect_config.apply_to_config(config, resurrect)
workspace_switcher.apply_to_config(config)

-- Workspace switcher events
wezterm.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
	resurrect.workspace_state.restore_workspace(resurrect.state_manager.load_state(label, "workspace"), {
		window = window,
		relative = true,
		restore_text = true,
		resize_window = false,
		on_pane_restore = resurrect.tab_state.default_on_pane_restore,
	})
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.chosen", function(window, path, label)
	window:gui_window():set_right_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Foreground = { Color = theme.palette.mauve } },
		{ Text = utils.basename(path) .. "  " },
	}))
end)

wezterm.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
	resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
	resurrect.state_manager.write_current_state(label, "workspace")
end)

wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)

return config
