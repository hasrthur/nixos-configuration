local config = wezterm.config_builder()

config.enable_wayland = false
config.color_scheme = 'Snazzy'
config.font = wezterm.font 'FiraCode Nerd Font'
config.font_size = 14
config.window_padding = {
  left = '1cell',
  right = '1cell',
  top = '0.5cell',
  bottom = '0.5cell'
}

return config