{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hyprcursor
    hyprland-per-window-layout
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hypr.conf;
  };

  home = {
    file.".config/hypr" = {
      source = ./configs;
      recursive = true;
    };

    pointerCursor.hyprcursor.enable = true;
  };

  services.hyprpolkitagent.enable = true;

  programs.wayprompt = {
    enable = true;
    package = pkgs.wayprompt;
  };

#   xdg.portal =
# {
#   enable = true;
#   extraPortals = with pkgs;
#   [
#     xdg-desktop-portal-wlr
#     xdg-desktop-portal-termfilechooser
#   ];
# };

# xdg.portal.config.common =
# {
#   "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
# };

# xdg.configFile."xdg-desktop-portal-termfilechooser/config" =
# {
#   force = true;
#   text =
#   ''
#     [filechooser]
#     cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
#     env=TERMCMD=ghostty --class=local.termfilechooser -e
#     open_mode = suggested
#     save_mode = last
#   '';
# };
}
