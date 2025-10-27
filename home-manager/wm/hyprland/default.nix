{ pkgs, ... }:

{
  home.packages = with pkgs; [
    blueberry
    hyprcursor
    hyprland-per-window-layout
    networkmanagerapplet

    pamixer
    wiremix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hypr.conf;
    systemd.enable = false;
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

  services.swayosd.enable = true;
  services.playerctld.enable = true;

  programs.jq.enable = true;

  # programs.ashell = {
  #   enable = true;
  #   systemd.enable = true;
  #   settings = {
  #     settings = {
  #       lock_cmd = "hyprlock &";
  #       audio_sinks_more_cmd = "pavucontrol -t 3";
  #       audio_sources_more_cmd = "pavucontrol -t 4";
  #       wifi_more_cmd = "nm-connection-editor";
  #       vpn_more_cmd = "nm-connection-editor";
  #       bluetooth_more_cmd = "blueman-manager";
  #       remove_airplane_btn = true;
  #       remove_idle_btn = true;
  #     };
  #   };
  # };
  # programs.quickshell.enable = true;
  # programs.quickshell.systemd.enable = true;

  # services.network-manager-applet.enable = true;

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
