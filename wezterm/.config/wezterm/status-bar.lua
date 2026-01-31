local wezterm = require("wezterm")
local theme = require("theme")

local M = {}

-- Pre-compute battery icons at module load time
local battery_icons = {
  [10] = wezterm.nerdfonts.md_battery_10,
  [20] = wezterm.nerdfonts.md_battery_20,
  [30] = wezterm.nerdfonts.md_battery_30,
  [40] = wezterm.nerdfonts.md_battery_40,
  [50] = wezterm.nerdfonts.md_battery_50,
  [60] = wezterm.nerdfonts.md_battery_60,
  [70] = wezterm.nerdfonts.md_battery_70,
  [80] = wezterm.nerdfonts.md_battery_80,
  [90] = wezterm.nerdfonts.md_battery_90,
  [100] = wezterm.nerdfonts.md_battery,
}

local charging_icons = {
  [10] = wezterm.nerdfonts.md_battery_charging_10,
  [20] = wezterm.nerdfonts.md_battery_charging_20,
  [30] = wezterm.nerdfonts.md_battery_charging_30,
  [40] = wezterm.nerdfonts.md_battery_charging_40,
  [50] = wezterm.nerdfonts.md_battery_charging_50,
  [60] = wezterm.nerdfonts.md_battery_charging_60,
  [70] = wezterm.nerdfonts.md_battery_charging_70,
  [80] = wezterm.nerdfonts.md_battery_charging_80,
  [90] = wezterm.nerdfonts.md_battery_charging_90,
  [100] = wezterm.nerdfonts.md_battery_charging_100,
}

local WORKSPACE_ICON = wezterm.nerdfonts.fae_planet

-- Battery info cache (avoid repeated system calls)
local cached_battery = nil
local battery_cache_time = 0
local BATTERY_CACHE_TTL = 30 -- seconds

local function get_battery_info()
  local now = os.time()
  if cached_battery and (now - battery_cache_time) < BATTERY_CACHE_TTL then
    return cached_battery
  end
  cached_battery = wezterm.battery_info()
  battery_cache_time = now
  return cached_battery
end

function M.apply_to_config(config)
  wezterm.on("update-right-status", function(window, pane)
    local cells = {}

    -- Date/time
    table.insert(cells, wezterm.strftime("%a %b %-d %H:%M"))

    -- Battery info (cached, refreshes every 30s)
    for _, b in ipairs(get_battery_info()) do
      local charge_level = math.floor(b.state_of_charge * 100)
      local nearest_ten = math.floor(charge_level / 10) * 10
      local icons = (b.state == "Charging" or b.state == "Unknown") and charging_icons or battery_icons
      local battery_icon = icons[nearest_ten] or icons[10]

      table.insert(cells, { [b.state] = battery_icon .. "  " .. string.format("%.0f%%", charge_level) })
    end

    -- Workspace info
    local workspace_name = window:active_workspace()
    if workspace_name == "" then
      table.insert(cells, WORKSPACE_ICON .. "    ")
    else
      table.insert(cells, workspace_name .. "  " .. WORKSPACE_ICON .. "  ")
    end

    -- Build formatted elements
    local elements = {}

    for i, cell in ipairs(cells) do
      local is_last = (i == #cells)

      if type(cell) == "table" then
        local battery_state, battery_value = next(cell)
        local color = theme.ui.battery[battery_state:lower()] or "#FFFFFF"

        table.insert(elements, { Foreground = { Color = color } })
        table.insert(elements, { Background = { Color = "none" } })
        table.insert(elements, { Text = " " .. tostring(battery_value) .. " " })
      else
        local fg = is_last and theme.palette.mauve or theme.palette.subtext0
        table.insert(elements, { Foreground = { Color = fg } })
        table.insert(elements, { Background = { Color = "none" } })
        table.insert(elements, { Text = " " .. cell .. " " })
      end

      if not is_last then
        table.insert(elements, { Foreground = { Color = theme.palette.surface1 } })
        table.insert(elements, { Text = "  | " })
      end
    end

    window:set_right_status(wezterm.format(elements))
  end)
end

return M
