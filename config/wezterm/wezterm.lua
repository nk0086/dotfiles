local wezterm = require 'wezterm'

return {
    -- フォント設定を修正
    font = wezterm.font('Cica', {
        weight = 'Regular',
        stretch = 'Normal',
        style = 'Normal'
    }),
    font_size = 14.0,
    use_ime = true,
    keys = {
        {key = 's', mods = 'ALT', action = wezterm.action.SplitHorizontal{domain = 'CurrentPaneDomain'}},
        {key = 'v', mods = 'ALT', action = wezterm.action.SplitVertical{domain = 'CurrentPaneDomain'}},
        {key = 'w', mods = 'ALT', action = wezterm.action.CloseCurrentPane{confirm = false}},
        {key = 'h', mods = 'SUPER', action = wezterm.action.ActivatePaneDirection('Left')},
        {key = 'j', mods = 'SUPER', action = wezterm.action.ActivatePaneDirection('Down')},
        {key = 'k', mods = 'SUPER', action = wezterm.action.ActivatePaneDirection('Up')},
        {key = 'l', mods = 'SUPER', action = wezterm.action.ActivatePaneDirection('Right')},
    },
      
    force_reverse_video_cursor = true,
    color_scheme = 'Ollie',
}
