{ pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./dconf.nix
  ];

  gtk.iconTheme = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };
}
