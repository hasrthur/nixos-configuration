{ username, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hyprcursor
    hyprland-per-window-layout
  ];

  programs.hyprland.enable = true;
  services.getty.autologinUser = username;
  services.xserver.displayManager.lightdm.enable = false; # Disable default display manager (ensure no other DMs are enabled)
  environment.loginShellInit = ''
    # Launch Hyprland on TTY1, return to TTY when exiting
    if [ "$(tty)" = "/dev/tty1" ]; then
      Hyprland # Use `exec Hyprland` to auto-restart on exit/crash instead
    fi
  '';
}
