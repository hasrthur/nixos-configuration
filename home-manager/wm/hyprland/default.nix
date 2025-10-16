{ pkgs, ... }:

{
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
}
