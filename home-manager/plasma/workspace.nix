{ pkgs, config, ... }:

{
  # home.packages = [ pkgs.papirus-icon-theme ];

  programs.plasma.workspace = {
    iconTheme = "breeze"; #"Papirus-Dark";
    theme = "breeze-dark";
    colorScheme = "BreezeDark";
    lookAndFeel = "org.kde.breezedark.desktop";
    wallpaper = config.stylix.image;
  };
}
