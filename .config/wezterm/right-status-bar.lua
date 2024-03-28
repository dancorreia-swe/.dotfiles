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
		for _, b in ipairs(wezterm.battery_info()) do
			table.insert(cells, string.format("%.0f%%", b.state_of_charge * 100))
		end

		-- The powerline < symbol
		-- local LEFT_ARROW = utf8.char(0xe0b3)
		-- The filled in variant of the < symbol
		local SOLID_LEFT_ARROW_STATUS = utf8.char(0xe0b2)

		-- Color palette for the backgrounds of each cell
		local colors = {
			"#323238",
			"#1E1E24",
			-- "#7c5295",
			-- "#b491c8",
		}

		local ROBOT_ICON = wezterm.nerdfonts.oct_dependabot
		local SATURN_ICON = wezterm.nerdfonts.fae_planet

		local workspace_icon = ""
		if window:active_workspace() == "default" then
			workspace_icon = SATURN_ICON
		else
			workspace_icon = ROBOT_ICON
		end

		table.insert(cells, window:active_workspace() .. " " .. workspace_icon)

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
		function push(text, is_last, is_first)
			local cell_no = num_cells + 1
			if is_first then
				table.insert(elements, { Foreground = { Color = colors[cell_no] } })
				table.insert(elements, { Text = SOLID_LEFT_ARROW_STATUS })
			end

			table.insert(elements, { Foreground = { Color = text_fg } })
			table.insert(elements, { Background = { Color = colors[cell_no] } })
			table.insert(elements, { Text = " " .. text .. " " })
			if not is_last then
				table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
				table.insert(elements, { Text = SOLID_LEFT_ARROW_STATUS })
			end
			num_cells = num_cells + 1
		end

		local is_first = true
		while #cells > 0 do
			local cell = table.remove(cells, 1)
			push(cell, #cells == 0, is_first)
			is_first = false
		end

		window:set_right_status(wezterm.format(elements))
	end)
end

return module
