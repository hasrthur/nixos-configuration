{ ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./configs/hypr.conf;
  };

  home.file.".config/hypr" = {
    source = ./configs/hyprland;
    recursive = true;
  };
}