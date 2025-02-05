local wezterm = require("wezterm")

local colors_config = require("wez-colorscheme")
local font_config = require("font")
local cursor_config = require("cursor")
local window_config = require("window")
local tab_bar_config = require("tab-bar")
local keybinds_config = require("keybinds")
local right_status_bar_config = require("right-status-bar")

local config = wezterm.config_builder()

font_config.apply_to_config(config)
window_config.apply_to_config(config)
cursor_config.apply_to_config(config)
tab_bar_config.apply_to_config(config)
right_status_bar_config.apply_to_config(config)
keybinds_config.apply_to_config(config)
colors_config.apply_to_config(config)

return config
