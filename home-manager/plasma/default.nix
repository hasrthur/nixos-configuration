{ pkgs, lib, ... }:

{
  imports = [
    ./config
    ./kwin.nix
    ./login.nix
    ./panels.nix
    ./shortcuts.nix
    ./window-rules.nix
    ./windows.nix
    ./workspace.nix
  ];

  programs.plasma = {
    enable = true;
    overrideConfig = true;
  };

  # plasma 6 is kinda broken with stylix
  stylix.targets.kde.enable = false;

  # home.activation.stylixLookAndFeel = lib.mkForce "";
}
