local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local front_app = sbar.add("item", "front_app", {
  position = "center",
  display = "active",
  icon = {
    string = app_icons["Default"],
    font = "sketchybar-app-font:Regular:16.0",
    padding_left = 8,
    padding_right = 8,
  },
  label = { drawing = false },
  background = {
    drawing = false,
    color = colors.transparent,
    border_color = colors.transparent,
    border_width = 0,
  },
  updates = true,
})

front_app:subscribe("front_app_switched", function(env)
  local icon = app_icons[env.INFO] or app_icons["Default"]
  front_app:set({ icon = { string = icon } })
end)

front_app:subscribe("mouse.clicked", function(env)
  sbar.trigger("swap_menus_and_spaces")
end)
