local module = {} -- the module table

function module.apply_to_config(config)
	config.default_cursor_style = "BlinkingBlock"
	config.cursor_blink_rate = 900
	config.cursor_blink_ease_in = "Constant"
	config.cursor_blink_ease_out = "Constant"
end

return module
