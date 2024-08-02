local config = wezterm.config_builder()

-- config.enable_wayland = true
config.window_padding = {
  left = '1cell',
  right = '1cell',
  top = '0.5cell',
  bottom = '0.5cell'
}
-- config.dpi = 384

return config