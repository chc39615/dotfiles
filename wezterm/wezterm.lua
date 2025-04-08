-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This table will hold the configuration
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error message
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

config.color_scheme = "tokyonight-storm"

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.enable_tab_bar = true
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.8,
}

config.font = wezterm.font_with_fallback({
	"Oxygen Mono",
	"JetBrainsMono Nerd Font Mono",
	"FiraCode Nerd Font",
})

config.default_prog = { "powershell.exe", "-NoLogo" }

config.window_padding = {
	left = 3,
	right = 3,
	top = 3,
	bottom = 3,
}

local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local SOLID_LEFT_ARROW = utf8.char(0xe0ba)
local SOLID_LEFT_MOST = utf8.char(0x2588)
local SOLID_RIGHT_ARROW = utf8.char(0xe0bc)

local ADMIN_ICON = utf8.char(0xf49c)

local CMD_ICON = utf8.char(0xe62a)
local NU_ICON = utf8.char(0xe7a8)
local PS_ICON = utf8.char(0xe70f)
local ELV_ICON = utf8.char(0xfc6f)
-- local WSL_ICON = utf8.char(0xf83c)
local WSL_ICON = utf8.char(0xf08c7)
local YORI_ICON = utf8.char(0xf1d4)
local NYA_ICON = utf8.char(0xf61a)

local VIM_ICON = utf8.char(0xe62b)
local PAGER_ICON = utf8.char(0xf718)
local FUZZY_ICON = utf8.char(0xf0b0)
local HOURGLASS_ICON = utf8.char(0xf252)
local SUNGLASS_ICON = utf8.char(0xf9df)

local PYTHON_ICON = utf8.char(0xf820)
local NODE_ICON = utf8.char(0xe74e)
local DENO_ICON = utf8.char(0xe628)
local LAMBDA_ICON = utf8.char(0xfb26)

local SUP_IDX = {
	"¹",
	"²",
	"³",
	"⁴",
	"⁵",
	"⁶",
	"⁷",
	"⁸",
	"⁹",
	"¹⁰",
	"¹¹",
	"¹²",
	"¹³",
	"¹⁴",
	"¹⁵",
	"¹⁶",
	"¹⁷",
	"¹⁸",
	"¹⁹",
	"²⁰",
}
local SUB_IDX = {
	"₁",
	"₂",
	"₃",
	"₄",
	"₅",
	"₆",
	"₇",
	"₈",
	"₉",
	"₁₀",
	"₁₁",
	"₁₂",
	"₁₃",
	"₁₄",
	"₁₅",
	"₁₆",
	"₁₇",
	"₁₈",
	"₁₉",
	"₂₀",
}

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
	max_width = 150
	local edge_background = "#121212"
	local background = "#4E4E4E"
	local foreground = "#1C1B19"
	local dim_foreground = "#3A3A3A"

	if tab.is_active then
		background = "#FBB829"
		foreground = "#1C1B19"
	elseif hover then
		background = "#FF8700"
		foreground = "#1C1B19"
	end

	local edge_foreground = background
	local process_name = tab.active_pane.foreground_process_name
	local pane_title = tab.active_pane.title
	local exec_name = basename(process_name):gsub("%.exe$", "")
	local title_with_icon

	if exec_name == "nu" then
		title_with_icon = NU_ICON .. " NuShell"
	elseif exec_name == "pwsh" or exec_name == "powershell" then
		title_with_icon = PS_ICON .. " PS"
	elseif exec_name == "cmd" then
		title_with_icon = CMD_ICON .. " CMD"
	elseif exec_name == "elvish" then
		title_with_icon = ELV_ICON .. " Elvish"
	elseif exec_name == "wsl" or exec_name == "wslhost" then
		title_with_icon = WSL_ICON .. " WSL"
	elseif exec_name == "nyagos" then
		title_with_icon = NYA_ICON .. " " .. pane_title:gsub(".*: (.+) %- .+", "%1")
	elseif exec_name == "yori" then
		title_with_icon = YORI_ICON .. " " .. pane_title:gsub(" %- Yori", "")
	elseif exec_name == "nvim" then
		title_with_icon = VIM_ICON .. pane_title:gsub("^(%S+)%s+(%d+/%d+) %- nvim", " %2 %1")
	elseif exec_name == "bat" or exec_name == "less" or exec_name == "moar" then
		title_with_icon = PAGER_ICON .. " " .. exec_name:upper()
	elseif exec_name == "fzf" or exec_name == "hs" or exec_name == "peco" then
		title_with_icon = FUZZY_ICON .. " " .. exec_name:upper()
	elseif exec_name == "btm" or exec_name == "ntop" then
		title_with_icon = SUNGLASS_ICON .. " " .. exec_name:upper()
	elseif exec_name == "python" or exec_name == "hiss" then
		title_with_icon = PYTHON_ICON .. " " .. exec_name
	elseif exec_name == "node" then
		title_with_icon = NODE_ICON .. " " .. exec_name:upper()
	elseif exec_name == "deno" then
		title_with_icon = DENO_ICON .. " " .. exec_name:upper()
	elseif exec_name == "bb" or exec_name == "cmd-clj" or exec_name == "janet" or exec_name == "hy" then
		title_with_icon = LAMBDA_ICON .. " " .. exec_name:gsub("bb", "Babashka"):gsub("cmd%-clj", "Clojure")
	else
		-- title_with_icon = HOURGLASS_ICON .. " " .. exec_name
		local is_nvim_process = string.find(process_name, "nvim-data", 1, true)
			or string.find(process_name, "language_server", 1, true)
		if is_nvim_process then
			title_with_icon = VIM_ICON .. "nvim"
		else
			title_with_icon = HOURGLASS_ICON .. " " .. exec_name
		end
	end
	if pane_title:match("^Administrator: ") then
		title_with_icon = title_with_icon .. " " .. ADMIN_ICON
	end
	local left_arrow = SOLID_LEFT_ARROW
	if tab.tab_index == 0 then
		left_arrow = SOLID_LEFT_MOST
	end
	local id = SUB_IDX[tab.tab_index + 1]
	local pid = SUP_IDX[tab.active_pane.pane_index + 1]

	local title = ""
	local tab_title = tab.tab_title
	if string.sub(tab_title, 1, 1) == "@" then
		title = " " .. wezterm.truncate_right(tab_title, max_width - 6) .. " "
	else
		title = " " .. wezterm.truncate_right(title_with_icon, max_width - 6) .. " "
	end
	-- title = " " .. wezterm.truncate_right(title_with_icon, max_width - 6) .. " "
	-- title = " " .. wezterm.truncate_right(tab.active_pane.title, max_width - 6) .. " "

	local function list_methods(obj)
		local methods = {}
		local mt = getmetatable(obj) -- Get the metatable
		if mt and mt.__index then
			for k, v in pairs(mt.__index) do
				if type(v) == "function" then
					table.insert(methods, k)
				end
			end
		end
		return methods
	end

	local methods = list_methods(tab)

	for _, method in ipairs(methods) do
		print(method)
	end

	return {
		{ Attribute = { Intensity = "Bold" } },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = left_arrow },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = id },
		{ Text = title },
		-- { Text = tab_title },
		{ Foreground = { Color = dim_foreground } },
		{ Text = pid },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
		{ Attribute = { Intensity = "Normal" } },
	}
end)

local launch_menu = {}
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	table.insert(launch_menu, {
		label = "PowerShell",
		args = { "powershell.exe", "-NoLogo" },
	})

	table.insert(launch_menu, {
		label = "CMD",
		args = { "cmd.exe" },
	})

	table.insert(launch_menu, {
		label = "WSL",
		args = { "wsl.exe" },
	})

	table.insert(launch_menu, {
		label = "ArchLinux",
		args = { "cmd.exe", "/c", "C:\\Users\\cody_zhang\\conn_arch.bat" },
	})
end

config.launch_menu = launch_menu
-- local mux = wezterm.mux
-- wezterm.on("gui-startup", function(spawnCmd)
-- 	if spawnCmd then
-- 		if #spawnCmd.args > 0 then
-- 			local findName = string.lower(spawnCmd.args[1])
-- 			for _, menuItem in ipairs(config.launch_menu) do
-- 				-- wezterm.log_info("Comparing launch first arg of: " .. findName .. " to: " .. string.lower(menuItem.label))
-- 				if string.lower(menuItem.label) == findName then
-- 					mux.spawn_window(menuItem)
-- 				end
-- 			end
-- 		end
-- 	end
-- end)

local function recompute_padding(window)
	local window_dims = window:get_dimensions()
	local overrides = window:get_config_overrides() or {}
	if not window_dims.is_full_screen then
		if not overrides.window_padding then
			return
		end
		overrides.window_padding = nil
	else
		local third = math.floor(window_dims.pixel_width / 3)
		local new_padding = {
			left = third,
			right = third,
			top = 0,
			bottom = 0,
		}
		if overrides.window_padding and new_padding.left == overrides.window_padding.left then
			return
		end
		overrides.window_padding = new_padding
	end
	window:set_config_overrides(overrides)
end
wezterm.on("window-resized", function(window, _)
	recompute_padding(window)
end)
wezterm.on("window-config-reloaded", function(window, _)
	recompute_padding(window)
end)

local function is_tmux_active()
	local p = io.popen("test -n '$TMUX'")
	if p == nil then
		return false
	end
	local output = p:read("*a")
	p:close()
	return output == "1\n"
	-- local result = wezterm.cmd_capture_async("test -n '$TMUX'") == "1"
	-- return result
end

-- config.allow_win32_input_mode = false
-- config.enable_csi_u_key_encoding = true

config.leader = { key = "t", mods = "ALT|CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{ key = "|", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "LeftArrow", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "z", mods = "ALT", action = act.ShowLauncher },
	{ key = "L", mods = "CTRL", action = act.ShowDebugOverlay },

	-- send special key to termial
	{ key = "F5", mods = "CTRL|SHIFT", action = act.SendString("\x1b[15;6;5~") }, -- CTRL+SHIFT+F5
	{ key = "F5", mods = "SHIFT", action = act.SendString("\x1b[15;4~") }, -- SHIFT+F5
	{ key = "F9", mods = "SHIFT", action = act.SendString("\x1b[20;4~") }, -- SHIFT+F9
	{ key = "F11", mods = "SHIFT", action = act.SendString("\x1b[23;4~") }, -- SHIFT+F11

	-- rename tab
	{
		key = "e",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab (empty for reset)",
			-- initial_value = 'My Tab Name',
			action = wezterm.action_callback(function(window, pane, line)
				if line == "" then
					local process_name = pane:get_foreground_process_name()
					local exec_name = basename(process_name):gsub("%.exe$", "")
					window:active_tab():set_title(exec_name)
				else
					window:active_tab():set_title("@" .. line)
				end
			end),
		}),
	},

	-- {
	-- 	key = "DownArrow",
	-- 	mods = "ALT",
	-- 	action = is_tmux_active() and wezterm.send_key(key, mods) or act.ActivatePaneDirection("Down"),
	-- },
}

config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(act.ClearSelection, pane)
			else
				window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
			end
		end),
	},
}

-- and finally, return the configuration to wezterm
return config
