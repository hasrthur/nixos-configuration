{ config, nixpkgs, inputs, ...}:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    ./hardware-configuration.nix
    ./kernel.nix
    ./bootloader.nix
    ./nvidia.nix
    ./networking.nix
    ./shell.nix
    ./nix.nix
    ./wm.nix
    ./media.nix
    ./timezone.nix
    ./users.nix
    ./packages.nix
    ./fonts.nix
  ];
}