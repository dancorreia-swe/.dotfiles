local module = {}

function module.apply_to_config(config)
	config.color_scheme = "Catppuccin Mocha"
	config.colors = {
		tab_bar = {
			background = "rgba(0, 0, 0, 0.2)",
		},
		cursor_bg = "#f6c177",
		cursor_border = "#ea9d34",
		-- background = "#15131E",
	}
end

return module
