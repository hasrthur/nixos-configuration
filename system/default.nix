{ config, pkgs, nixpkgs, inputs, ...}:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    ./hardware-configuration.nix
    ./kernel.nix
    ./bootloader.nix
    ./video-graphics.nix
    ./bluetooth.nix
    ./networking.nix
    ./shell.nix
    ./nix.nix
    ./wm.nix
    ./media.nix
    ./timezone.nix
    ./users.nix
    ./stylix.nix
    # ./udisks.nix
    # ./thunar.nix
    # ./hybernation.nix
    ./wayland.nix
    ./docker.nix
    ./hosts.nix
    ./plasma.nix
  ];
}
