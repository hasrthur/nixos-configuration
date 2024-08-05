{ ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hypr.conf;
  };

  home.file.".config/hypr" = {
    source = ./configs;
    recursive = true;
  };
}