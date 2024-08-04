{ pkgs, config, ... }:

{
  stylix = {
    enable = true;
    polarity = "dark";
    image = ../images/wallpapers/CuteCat.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/snazzy.yaml";
    fonts = {
      monospace = {
        name = "CaskaydiaCove Nerd Font Propo";
        package = pkgs.nerdfonts;
      };
      serif = config.stylix.fonts.monospace;
      sansSerif = config.stylix.fonts.monospace;

      sizes = {
        applications = 14;
        desktop = 14;
        popups = 16;
        terminal = 14;
      };
    };
    opacity = {
      applications = 0.9;
      desktop = 0.9;
      popups = 0.9;
      terminal = 0.9;
    };
    targets = {
      grub.useImage = true;
      nixos-icons.enable = true;
    };
  };
}