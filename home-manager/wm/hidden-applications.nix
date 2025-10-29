{ lib, ... }:

let
  applications = [
    "kvantummanager"
    "nm-connection-editor"
    "nvidia-settings"
    "rofi"
    "rofi-theme-selector"
    "qt5ct"
    "qt6ct"
  ];
in
{
  xdg.desktopEntries = builtins.listToAttrs (builtins.map (app: {
    name = app;
    value = { noDisplay = true; name = ""; };
  }) applications);
}
