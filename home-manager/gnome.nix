{ lib, pkgs, ... }:

{
  home.packages = [ pkgs.dconf2nix ];

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };
}
