local wezterm = require("wezterm")
local utils = require("utils")

local M = {}

-- Cache the resurrect plugin reference (passed from main config or loaded once)
local resurrect = nil

local function get_resurrect()
	if not resurrect then
		resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
	end
	return resurrect
end

function M.apply_to_config(config, resurrect_instance)
	-- Use passed instance or load once
	resurrect = resurrect_instance or get_resurrect()

	local resurrect_keys = {
		{
			key = "w",
			mods = "LEADER",
			action = wezterm.action_callback(function(win, pane)
				resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
			end),
		},
		{
			key = "W",
			mods = "LEADER",
			action = resurrect.window_state.save_window_action(),
		},
		{
			key = "t",
			mods = "LEADER",
			action = resurrect.tab_state.save_tab_action(),
		},
		{
			key = "s",
			mods = "CMD",
			action = wezterm.action_callback(function(win, pane)
				resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
				resurrect.window_state.save_window_action()
			end),
		},
		{
			key = "r",
			mods = "LEADER",
			action = wezterm.action_callback(function(win, pane)
				resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
					local state_type = string.match(id, "^([^/]+)") -- match before '/'
					id = string.match(id, "([^/]+)$") -- match after '/'
					id = string.match(id, "(.+)%..+$") -- remove file extension
					local opts = {
						relative = true,
						restore_text = true,
						on_pane_restore = resurrect.tab_state.default_on_pane_restore,
					}
					if state_type == "workspace" then
						local state = resurrect.state_manager.load_state(id, "workspace")
						resurrect.workspace_state.restore_workspace(state, opts)
					elseif state_type == "window" then
						local state = resurrect.state_manager.load_state(id, "window")
						resurrect.window_state.restore_window(pane:window(), state, opts)
					elseif state_type == "tab" then
						local state = resurrect.state_manager.load_state(id, "tab")
						resurrect.tab_state.restore_tab(pane:tab(), state, opts)
					end
				end)
			end),
		},
		{
			key = "d",
			mods = "LEADER",
			action = wezterm.action_callback(function(win, pane)
				resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
					resurrect.state_manager.delete_state(id)
				end, {
					title = "Delete State",
					description = "Select State to Delete and press Enter = accept, Esc = cancel, / = filter",
					fuzzy_description = "Search State to Delete: ",
					is_fuzzy = true,
				})
			end),
		},
	}

	config.keys = utils.merge_arrays(config.keys, resurrect_keys)

	-- Error handler for resurrect (only register once)
	wezterm.on("resurrect.error", function(err)
		wezterm.log_error("resurrect error: " .. tostring(err))
		local windows = wezterm.gui.gui_windows()
		if windows and windows[1] then
			windows[1]:toast_notification("resurrect", err, nil, 3000)
		end
	end)
end

return M
