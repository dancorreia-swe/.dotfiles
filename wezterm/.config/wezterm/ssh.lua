local wezterm = require("wezterm")
local act = wezterm.action

local module = {}

-- Build optimized SSH domains from ~/.ssh/config
local function build_ssh_domains()
	local domains = {}
	local default_domains = wezterm.default_ssh_domains()

	for _, dom in ipairs(default_domains) do
		table.insert(domains, {
			name = dom.name,
			remote_address = dom.remote_address,
			username = dom.username,
			-- Posix shell for proper cwd tracking
			assume_shell = "Posix",
			-- Keep connection alive (nightly feature)
			ssh_option = {
				ServerAliveInterval = "30",
			},
		})
	end

	return domains
end

-- Build choices for the SSH picker
local function build_ssh_choices()
	local choices = {}
	local domains = wezterm.default_ssh_domains()

	for _, dom in ipairs(domains) do
		local user = dom.username or "root"
		table.insert(choices, {
			id = dom.name,
			label = wezterm.nerdfonts.md_ssh .. "  " .. dom.name .. " (" .. user .. "@" .. dom.remote_address .. ")",
		})
	end

	return choices
end

function module.apply_to_config(config)
	-- Set up optimized SSH domains
	config.ssh_domains = build_ssh_domains()
end

function module.get_keybinds()
	local ssh_choices = build_ssh_choices()

	return {
		-- SSH host picker (Leader + h)
		{
			key = "h",
			mods = "LEADER",
			action = act.InputSelector({
				title = " SSH Hosts",
				choices = ssh_choices,
				fuzzy = true,
				action = wezterm.action_callback(function(window, pane, id, label)
					if id then
						window:perform_action(
							act.SpawnCommandInNewTab({
								domain = { DomainName = id },
							}),
							pane
						)
					end
				end),
			}),
		},
		-- SSH + tmux control mode (Leader + T)
		{
			key = "T",
			mods = "LEADER",
			action = act.InputSelector({
				title = " SSH + tmux",
				choices = ssh_choices,
				fuzzy = true,
				action = wezterm.action_callback(function(window, pane, id, label)
					if id then
						-- Extract host from domain name (e.g., "SSH:hetzner" -> "hetzner")
						local host = id:gsub("^SSH:", "")
						window:perform_action(
							act.SpawnCommandInNewTab({
								args = { "ssh", host, "-t", "tmux", "-CC", "new", "-A", "-s", "main" },
							}),
							pane
						)
					end
				end),
			}),
		},
		-- SSH in current pane's domain - new tab (Leader + H)
		{
			key = "H",
			mods = "LEADER",
			action = act.SpawnCommandInNewTab({
				domain = "CurrentPaneDomain",
			}),
		},
	}
end

return module
