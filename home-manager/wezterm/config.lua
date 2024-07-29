local config = wezterm.config_builder()

config.enable_wayland = false
config.window_padding = {
  left = '1cell',
  right = '1cell',
  top = '0.5cell',
  bottom = '0.5cell'
}

return config