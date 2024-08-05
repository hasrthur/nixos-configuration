{ lib, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = lib.mkAfter (builtins.readFile ./style.css);
  };

  home.file.".config/waybar/config.jsonc" = {
    source = ./config.jsonc;
  };
}