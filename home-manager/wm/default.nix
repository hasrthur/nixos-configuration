{ config, pkgs, username, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./configs/hypr.conf;
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  home.file.".config/waybar" = {
    source = ./configs/waybar;
    recursive = true;
  };
}