local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Start the keyboard layout monitor event provider
sbar.exec(
	"killall keyboard_layout_monitor >/dev/null 2>&1; $CONFIG_DIR/helpers/event_providers/keyboard_layout/bin/keyboard_layout_monitor &"
)

local keyboard_layout = sbar.add("item", "widgets.keyboard_layout", {
	position = "right",
	label = {
		font = {
			family = settings.font.numbers,
			size = 16.0,
		},
		padding_left = 0,
		string = "US",
	},
})

local function format_layout(layout)
	if not layout or layout == "" then
		return "??"
	end

	layout = layout:gsub("%s+", "")

	if layout:match("U%.S%.") or layout:match("US") then
		return "US"
	elseif layout:match("Brazilian%–ABNT2") then
		return "BR"
	elseif layout:match("British") then
		return "UK"
	elseif layout:match("French") then
		return "FR"
	elseif layout:match("German") then
		return "DE"
	elseif layout:match("Spanish") then
		return "ES"
	elseif layout:match("Italian") then
		return "IT"
	elseif layout:match("Portuguese") then
		return "PT"
	elseif layout:match("Russian") then
		return "RU"
	elseif layout:match("Japanese") then
		return "JP"
	elseif layout:match("Korean") then
		return "KR"
	elseif layout:match("Chinese") then
		return "CN"
	else
		return layout:sub(1, 3):upper()
	end
end

keyboard_layout:subscribe("keyboard_layout_changed", function(env)
	local layout = format_layout(env.layout)
	keyboard_layout:set({
		label = { string = layout },
	})
end)

keyboard_layout:subscribe("system_woke", function()
	sbar.exec(
		"killall keyboard_layout_monitor >/dev/null 2>&1; $CONFIG_DIR/helpers/event_providers/keyboard_layout/bin/keyboard_layout_monitor &"
	)
end)

sbar.add("bracket", "widgets.keyboard_layout.bracket", { keyboard_layout.name }, {
	background = { color = colors.transparent, border_width = 0 },
})

sbar.add("item", "widgets.keyboard_layout.padding", {
	position = "right",
	width = settings.group_paddings,
})
