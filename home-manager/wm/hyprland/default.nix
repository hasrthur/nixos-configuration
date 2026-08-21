{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hyprcursor
    hyprland-per-window-layout
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    extraConfig = builtins.readFile ./hypr.lua;
    systemd.enable = false;

    extraLuaFiles = {
      # required explicitly by the modules below, so not auto-loaded
      vars = {
        content = ./configs/vars.lua;
        autoLoad = false;
      };

      env = ./configs/env.lua;
      execs = ./configs/execs.lua;
      keyboard = ./configs/keyboard.lua;
      monitors = ./configs/monitors.lua;
      noborders = ./configs/noborders.lua;
      windowrules = ./configs/windowrules.lua;
      workspaces = ./configs/workspaces.lua;

      bindings = ./configs/bindings.lua;
      "bindings.clipboard" = ./configs/bindings/clipboard.lua;
      "bindings.keyboard_layouts" = ./configs/bindings/keyboard_layouts.lua;
      "bindings.launcher" = ./configs/bindings/launcher.lua;
      "bindings.media" = ./configs/bindings/media.lua;
      "bindings.notifications" = ./configs/bindings/notifications.lua;
    };

    xdph.settings.screencopy = {
      max_fps = 60;
      allow_token_by_default = true;
    };
  };

  home.pointerCursor.hyprcursor.enable = true;

  services.hyprpolkitagent.enable = true;

  # programs.wayprompt = {
  #   enable = true;
  #   package = pkgs.wayprompt;
  # };

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
