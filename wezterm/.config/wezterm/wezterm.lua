local wezterm = require("wezterm")
local act = wezterm.action

config = wezterm.config_builder()

-- Detect OS
local function is_darwin()
	return wezterm.target_triple:find("darwin") ~= nil
end

local function is_linux()
	return wezterm.target_triple:find("linux") ~= nil
end

local function is_arch()
	-- Check if running on Arch Linux
	local handle = io.popen("cat /etc/os-release 2>/dev/null | grep -i 'ID=arch'")
	if handle then
		local result = handle:read("*a")
		handle:close()
		return result:find("arch") ~= nil
	end
	return false
end

-- OS-specific settings
local font_config = {}
local cursor_config = {}
local padding_config = {}

if is_darwin() then
	-- macOS settings
	font_config = {
		font = wezterm.font("D2CodingLigature Nerd Font Mono"),
		font_size = 17,
	}
	cursor_config = {
		default_cursor_style = "BlinkingBar",
	}
	padding_config = {
		left = 3,
		right = 3,
		top = 0,
		bottom = 0,
	}
elseif is_linux() then
	-- Linux settings (including Arch)
	font_config = {
		font = wezterm.font('JetBrains Mono Nerd Font', { weight = 'Regular' }),
		font_size = 11.0,
	}
	cursor_config = {
		default_cursor_style = "SteadyBlock",
		cursor_blink_rate = 0,
	}
	padding_config = {
		left = 14,
		right = 14,
		top = 14,
		bottom = 14,
	}
end

config = {
	-- Appearance settings from dotfile
	automatically_reload_config = true,
	color_scheme = "Synthwave2077",
	window_background_opacity = 0.75,
	macos_window_background_blur = 20,

	-- OS-specific font settings
	font = font_config.font,
	font_size = font_config.font_size,

	-- OS-specific cursor settings
	default_cursor_style = cursor_config.default_cursor_style,
	cursor_blink_rate = cursor_config.cursor_blink_rate,

	-- Window settings (common + local preferences)
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",
	window_padding = padding_config,

	-- Linux-specific settings from local config
	enable_wayland = is_linux() and false or nil,
	term = is_linux() and "xterm-256color" or nil,
	hide_mouse_cursor_when_typing = false,

	-- Key bindings from local config
	keys = {
		-- Ctrl+Insert = copy
		{ key = "Insert", mods = "CTRL",       action = act.CopyTo "PrimarySelection" },
		-- Shift+Insert = paste
		{ key = "Insert", mods = "SHIFT",      action = act.PasteFrom "PrimarySelection" },
		-- Conventional copy/paste
		{ key = "c",      mods = "CTRL|SHIFT", action = act.CopyTo "ClipboardAndPrimarySelection" },
		{ key = "v",      mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },
	},

	-- Mouse bindings from local config
	mouse_bindings = {
		-- Middle-click paste
		{
			event = { Up = { streak = 1, button = 'Middle' } },
			mods = 'NONE',
			action = act.PasteFrom 'PrimarySelection',
		},
		-- Right-click paste
		{
			event = { Up = { streak = 1, button = 'Right' } },
			mods = 'NONE',
			action = act.PasteFrom 'PrimarySelection',
		},
	},
}

return config
