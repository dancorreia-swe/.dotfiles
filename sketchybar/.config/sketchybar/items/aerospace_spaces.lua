local colors = require("colors")
local settings = require("settings")

sbar.add("event", "aerospace_workspace_change")

local workspaces = { "1", "2", "3", "0", "A", "C", "F", "M", "N", "T", "W" }
local max_apps = 3
local slots = {}
local refresh_pending = false

local function set_slot_apps(workspace, apps, active)
  local slot = slots[workspace]
  if not slot then return end

  for i = 1, max_apps do
    local bundle_id = apps[i]
    if bundle_id then
      slot.apps[i]:set({
        drawing = true,
        background = {
          image = {
            string = "app." .. bundle_id,
            scale = active and 1.0 or 0.80,
            corner_radius = 5,
          },
        },
      })
    else
      slot.apps[i]:set({ drawing = false })
    end
  end
end

local function workspace_apps(raw)
  local by_workspace = {}

  for line in string.gmatch(raw or "", "[^\r\n]+") do
    local workspace, bundle_id = line:match("^([^|]+)|(.+)$")
    if workspace and bundle_id then
      by_workspace[workspace] = by_workspace[workspace] or { seen = {}, apps = {} }
      local bucket = by_workspace[workspace]

      if not bucket.seen[bundle_id] and #bucket.apps < max_apps then
        bucket.seen[bundle_id] = true
        table.insert(bucket.apps, bundle_id)
      end
    end
  end

  return by_workspace
end

local function paint_workspace(workspace, focused_workspace, apps_by_workspace)
  local active = workspace == focused_workspace
  local slot = slots[workspace]
  if not slot then return end
  local bucket = apps_by_workspace[workspace]

  slot.label:set({
    icon = {
      color = active and colors.lavender or colors.overlay1,
      padding_left = 4,
      padding_right = 4,
    },
  })
  slot.bracket:set({
    background = {
      drawing = false,
    },
  })

  set_slot_apps(workspace, bucket and bucket.apps or {}, active)
end

local function refresh(focused_workspace)
  if refresh_pending then return end
  refresh_pending = true

  local function paint_all(focused, apps_raw)
    local apps_by_workspace = workspace_apps(apps_raw)
    for _, workspace in ipairs(workspaces) do
      paint_workspace(workspace, focused, apps_by_workspace)
    end
    refresh_pending = false
  end

  local function fetch_apps(focused)
    sbar.exec("aerospace list-windows --all --format '%{workspace}|%{app-bundle-id}' 2>/dev/null", function(result)
      paint_all(focused, result)
    end)
  end

  if focused_workspace and focused_workspace ~= "" then
    fetch_apps(focused_workspace)
  else
    sbar.exec("aerospace list-workspaces --focused 2>/dev/null | head -n 1", function(result)
      fetch_apps((result or ""):gsub("%s+", ""))
    end)
  end
end

local watcher = sbar.add("item", "aerospace.watcher", {
  drawing = false,
  updates = true,
  update_freq = 5,
})

watcher:subscribe({ "routine", "forced", "aerospace_workspace_change" }, function(env)
  refresh(env.FOCUSED_WORKSPACE)
end)

watcher:subscribe("front_app_switched", function()
  if not refresh_pending then
    sbar.delay(0.2, function()
      refresh()
    end)
  end
end)

for _, workspace in ipairs(workspaces) do
  local label = sbar.add("item", "space." .. workspace, {
    position = "left",
    icon = {
      string = workspace,
      font = {
        family = settings.font.numbers,
        style = settings.font.style_map["Bold"],
        size = 12.0,
      },
      color = colors.overlay1,
      padding_left = 4,
      padding_right = 4,
      y_offset = 1,
    },
    label = { drawing = false },
    background = { drawing = false },
    padding_left = 0,
    padding_right = 0,
    click_script = "aerospace workspace " .. workspace,
  })

  local apps = {}
  local members = { label.name }
  for i = 1, max_apps do
    local app = sbar.add("item", "space." .. workspace .. ".app." .. i, {
      position = "left",
      drawing = false,
      icon = { drawing = false },
      label = { drawing = false },
      padding_left = 1,
      padding_right = 2,
      background = {
        drawing = true,
        color = colors.transparent,
        image = {
          scale = 0.80,
          corner_radius = 5,
        },
      },
    })
    apps[i] = app
    table.insert(members, app.name)
  end

  local bracket = sbar.add("bracket", "space." .. workspace .. ".bracket", members, {
    background = {
      drawing = false,
      color = colors.transparent,
      border_color = colors.transparent,
      border_width = 0,
      height = 24,
      corner_radius = 7,
    },
  })

  slots[workspace] = { label = label, apps = apps, bracket = bracket }
end

refresh()
