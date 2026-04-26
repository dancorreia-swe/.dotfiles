local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	position = "top",
	color = colors.bar.bg,
	border_color = colors.bar.border,
	border_width = 1,
	margin = 12,
	height = 40,
	y_offset = 6,
	blur_radius = 64,
	corner_radius = 16,
	padding_right = 2,
	padding_left = 2,
	font_smoothing = true,
})
