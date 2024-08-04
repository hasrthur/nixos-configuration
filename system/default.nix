{ config, nixpkgs, inputs, ...}:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    ./hardware-configuration.nix
    ./kernel.nix
    ./bootloader.nix
    ./nvidia.nix
    ./bluetooth.nix
    ./networking.nix
    ./shell.nix
    ./nix.nix
    ./wm.nix
    ./media.nix
    ./timezone.nix
    ./users.nix
    ./packages.nix
    ./fonts.nix
    ./stylix.nix
    ./udisks.nix
    ./thunar.nix
    ./hybernation.nix
    ./wayland.nix
    ./clipboard.nix
  ];
}