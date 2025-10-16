{ pkgs, lib, ... }:

{
  # service.displayManager
  # services = {
  #   desktopManager.plasma6.enable = false;
  #   displayManager = {
  #     sddm = {
  #       enable = false;
  #       # theme = "breeze-dark";
  #       wayland.enable = true;
  #     };
  #   };
  # };

  # environment.plasma6.excludePackages = with pkgs.kdePackages; [
  #   konsole
  #   kate
  #   elisa
  #   ktnef
  # ];

  # services.displayManager.gdm.enable = true;
  # services.desktopManager.gnome.enable = true;

  # environment.gnome.excludePackages = [ pkgs.gnome-tour ];

  # services.xserver.excludePackages = with pkgs; [ xterm ];
  documentation.doc.enable = false;

  # kmail doesn't support google oauth and it's fucking 2024
  # programs.kde-pim.kmail = true;
  # programs.kde-pim.merkuro = true;
  # hardware.pulseaudio.enable = false;

  # xdg.portal = {
  #   enable = true;
  #   extraPortals = with pkgs; [
  #     xdg-desktop-portal-gnome
  #     xdg-desktop-portal-gtk
  #   ];
  #   config = {
  #     hyprland = {
  #       default = lib.mkBefore [ "gtk" "hyprland" ];
  #       "org.freedesktop.impl.portal.ScreenCast" = [
  #         "gnome"
  #       ];
  #     };
  #   };
  # };

  services = {
    xserver = {
      xkb = {
        layout = "us,ua";
        options = "grp:ctrl_space_toggle";
      };
    };
  };
}
