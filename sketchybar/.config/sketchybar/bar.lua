local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	position = "top",
	color = colors.bar.bg,
	margin = 8,
	height = 40,
	y_offset = 8,
	blur_radius = 40,
	corner_radius = 16,
	padding_right = 2,
	padding_left = 2,
})
