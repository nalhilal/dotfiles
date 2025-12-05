local wezterm = require("wezterm")

config = wezterm.config_builder()

config = {
	automatically_reload_config = true,
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE", -- disable the title bar but enable the resizable border
	default_cursor_style = "BlinkingBar",
	color_scheme = "Synthwave2077",
	font = wezterm.font("D2CodingLigature Nerd Font Mono"),
	font_size = 17,
	window_background_opacity = 0.75,
	macos_window_background_blur = 20,
	window_padding = {
		left = 3,
		right = 3,
		top = 0,
		bottom = 0,
	},
}

return config
