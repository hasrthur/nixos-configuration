{ username, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # services.gnome.sushi.enable = true;
}
