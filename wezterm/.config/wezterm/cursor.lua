local M = {}

function M.apply_to_config(config)
	config.default_cursor_style = "BlinkingBlock"
	-- Performance: Slower blink rate reduces redraws (set to 0 to disable blinking)
	config.cursor_blink_rate = 900
	-- Performance: Constant easing avoids animation calculations
	config.cursor_blink_ease_in = "Constant"
	config.cursor_blink_ease_out = "Constant"
end

return M
