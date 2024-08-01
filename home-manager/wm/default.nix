{ config, pkgs, lib, username, ... }:

{

  imports = [
    ./rofi.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./configs/hypr.conf;
  };

  home.file.".config/hypr" = {
    source = ./configs/hyprland;
    recursive = true;
  };

  # programs.hyprlock = {
  #   enable = true;
  #   extraConfig = builtins.readFile ./configs/hyprlock.conf;
  # };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = lib.mkAfter (builtins.readFile ./configs/waybar/style.css);
  };

  home.file.".config/waybar/config.jsonc" = {
    source = ./configs/waybar/config.jsonc;
    recursive = false;
  };
}