{ lib, ... }:

{
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