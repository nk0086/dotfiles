local wezterm = require 'wezterm'

return {
    font = wezterm.font("Cica", {weight="Regular", stretch="Normal", italic=false}),
    font_size = 14.0,
    use_ime = true,
    keys = {
	{key = "f", mods = "ALT", action = wezterm.action.SplitHorizontal{domain = "CurrentPaneDomain"}},
	{key = "d", mods = "ALT", action = wezterm.action.SplitVertical{domain = "CurrentPaneDomain"}},
	{key = "w", mods = "ALT", action = wezterm.action.CloseCurrentPane{confirm = false}},
	{key = "h", mods = "SUPER", action = wezterm.action.ActivatePaneDirection "Left"},
	{key = "j", mods = "SUPER", action = wezterm.action.ActivatePaneDirection "Down"},
	{key = "k", mods = "SUPER", action = wezterm.action.ActivatePaneDirection "Up"},
	{key = "l", mods = "SUPER", action = wezterm.action.ActivatePaneDirection "Right"},
    },
      
    force_reverse_video_cursor = true,
    color_scheme = "Ollie",
}
