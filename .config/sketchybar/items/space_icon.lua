local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local space_icon = sbar.add("item", "space_icon", {
  icon = {
    font = { size = 16.0 },
    string = icons.spaces.other,
  },
  label = { drawing = false },
  background = {
    color = colors.transparent,
    border_color = colors.transparent,
    border_width = 0
  },
  padding_left = -1,
  padding_right = 0,
  width = 36
})

local function update_space_icon()
  sbar.exec("yabai -m query --spaces --space | jq -r .label", function(space_name)
    local space_label = space_name:gsub("%s+", "")
    local icon_string = icons.spaces[space_label] or icons.spaces.unknown
    space_icon:set({ icon = { string = icon_string } })
  end)
end

space_icon:subscribe("space_change", update_space_icon)
