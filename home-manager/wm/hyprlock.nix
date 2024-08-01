{ ... }:

{
  programs.hyprlock = {
    enable = true;
    extraConfig = builtins.readFile ./configs/hyprlock.conf;
  };
}