-- Centralized theme/color definitions (Catppuccin Mocha)
local M = {}

-- Base Catppuccin Mocha palette
M.palette = {
	rosewater = "#f5e0dc",
	flamingo = "#f2cdcd",
	pink = "#f5c2e7",
	mauve = "#cba6f7",
	red = "#f38ba8",
	maroon = "#eba0ac",
	peach = "#fab387",
	yellow = "#f9e2af",
	green = "#a6e3a1",
	teal = "#94e2d5",
	sky = "#89dceb",
	sapphire = "#74c7ec",
	blue = "#89b4fa",
	lavender = "#b4befe",
	text = "#cdd6f4",
	subtext1 = "#bac2de",
	subtext0 = "#a6adc8",
	overlay2 = "#9399b2",
	overlay1 = "#7f849c",
	overlay0 = "#6c7086",
	surface2 = "#585b70",
	surface1 = "#45475a",
	surface0 = "#313244",
	base = "#1e1e2e",
	mantle = "#181825",
	crust = "#11111b",
}

-- Semantic colors for UI elements
M.ui = {
	-- Tab bar
	active_tab_bg = M.palette.surface0,
	active_tab_fg = M.palette.text,
	inactive_tab_fg = M.palette.surface2,

	-- Status bar
	separator = M.palette.surface1,
	workspace_active = M.palette.mauve,
	workspace_default = M.palette.crust,

	-- Battery states
	battery = {
		discharging = "#FFA066",
		charging = M.palette.green,
		unknown = M.palette.blue,
		empty = M.palette.red,
	},
}

-- Process icon colors (for tab bar)
M.process = {
	editor = M.palette.blue,     -- nvim, vim
	runtime = M.palette.green,   -- node
	python = M.palette.yellow,
	git = M.palette.peach,
	ssh = M.palette.teal,
	shell = M.palette.lavender,  -- zsh, fish, bash
	elixir = M.palette.mauve,
	fallback = M.palette.text,
	fallback_inactive = M.palette.surface1,
}

-- Cursor colors
M.cursor = {
	bg = "#f6c177",
	border = "#ea9d34",
}

--- Apply base color scheme to config
function M.apply_to_config(config)
	config.color_scheme = "Catppuccin Mocha"
	config.colors = {
		tab_bar = {
			background = "rgba(0, 0, 0, 0.2)",
		},
		cursor_bg = M.cursor.bg,
		cursor_border = M.cursor.border,
	}
end

return M
