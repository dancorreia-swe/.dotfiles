local wezterm = require("wezterm")
local module = {}

function module.apply_to_config(config)
	wezterm.on("update-right-status", function(window, pane)
		-- Each element holds the text for a cell in a "powerline" style << fade
		local cells = {}

		-- Figure out the cwd and host of the current pane.
		-- This will pick up the hostname for the remote host if your
		-- shell is using OSC 7 on the remote host.
		-- local cwd_uri = pane:get_current_working_dir()
		-- if cwd_uri then
		-- 	local cwd = ""
		-- 	local hostname = ""
		--
		-- 	if type(cwd_uri) == "userdata" then
		-- 		-- Running on a newer version of wezterm and we have
		-- 		-- a URL object here, making this simple!
		--
		-- 		cwd = cwd_uri.file_path
		-- 		hostname = cwd_uri.host or wezterm.hostname()
		-- 	else
		-- 		-- an older version of wezterm, 20230712-072601-f4abf8fd or earlier,
		-- 		-- which doesn't have the Url object
		-- 		cwd_uri = cwd_uri:sub(8)
		-- 		local slash = cwd_uri:find("/")
		-- 		if slash then
		-- 			hostname = cwd_uri:sub(1, slash - 1)
		-- 			-- and extract the cwd from the uri, decoding %-encoding
		-- 			cwd = cwd_uri:sub(slash):gsub("%%(%x%x)", function(hex)
		-- 				return string.char(tonumber(hex, 16))
		-- 			end)
		-- 		end
		-- 	end
		--
		-- 	-- Remove the domain name portion of the hostname
		-- 	local dot = hostname:find("[.]")
		-- 	if dot then
		-- 		hostname = hostname:sub(1, dot - 1)
		-- 	end
		-- 	if hostname == "" then
		-- 		hostname = wezterm.hostname()
		-- 	end
		--
		-- 	-- table.insert(cells, cwd)
		-- 	-- table.insert(cells, hostname)
		-- end
		-- I like my date/time in this style: "Wed Mar 3 08:14"

		local date = wezterm.strftime("%a %b %-d %H:%M")
		table.insert(cells, date)

		-- An entry for each battery (typically 0 or 1 battery)
		local battery_percentage = {
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

		local charging_battery_percentage = {
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

		for _, b in ipairs(wezterm.battery_info()) do
			local charge_level = math.floor(b.state_of_charge * 100)
			local nearest_ten = math.floor(charge_level / 10) * 10
			local battery_status = (b.state == "Charging" or b.state == "Unknown") and charging_battery_percentage
				or battery_percentage
			local battery_icon = battery_status[nearest_ten] or battery_status[10]

			local battery_data = { [b.state] = battery_icon .. "  " .. string.format("%.0f%%", charge_level) }
			table.insert(cells, battery_data)
		end

		local colors = {
			"#1e1e2e",
			"#11111b",
			"#181825",
		}

		local ROBOT_ICON = wezterm.nerdfonts.oct_dependabot
		local SATURN_ICON = wezterm.nerdfonts.fae_planet

		local workspace_name = ""
		local workspace_icon = ""

		workspace_icon = SATURN_ICON
		workspace_name = window:active_workspace()

		if workspace_name == "" then
			table.insert(cells, workspace_icon .. "    ")
		else
			table.insert(cells, workspace_name .. "  " .. workspace_icon .. "  ")
		end

		if window:active_workspace() == "default" then
			table.insert(colors, "#0d0e0f")
		else
			table.insert(colors, "#D65d0e")
		end

		-- Foreground color for the text across the fade
		local text_fg = "#c0c0c0"

		-- The elements to be formatted
		local elements = {}
		-- How many cells have been formatted
		local num_cells = 0

		-- Translate a cell into elements
		local function push(text, is_last)
			if type(text) == "table" then
				local battery_state, battery_value = next(text)
				local battery_colors = {
					Discharging = "#FFA066",
					Charging = "#a6e3a1",
					Unknown = "#89b4fa",
					Empty = "#f38ba8",
				}
				local battery_color = battery_colors[battery_state] or "#FFFFFF"

				table.insert(elements, { Foreground = { Color = battery_color } })
				table.insert(elements, { Background = { Color = "none" } })
				table.insert(elements, { Text = " " .. tostring(battery_value) .. " " })
			else
				if is_last then
					text_fg = "#cba6f7"
				end

				table.insert(elements, { Foreground = { Color = text_fg } })
				table.insert(elements, { Background = { Color = "none" } })
				table.insert(elements, { Text = " " .. text .. " " })
			end

			if not is_last then
				table.insert(elements, { Foreground = { Color = "#45475a" } })
				table.insert(elements, { Text = "  " .. "| " })
			end
			num_cells = num_cells + 1
		end

		while #cells > 0 do
			local cell = table.remove(cells, 1)
			push(cell, #cells == 0)
		end

		window:set_right_status(wezterm.format(elements))
	end)
end

return module
