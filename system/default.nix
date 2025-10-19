{ inputs, ...}:

{
  imports = [
    inputs.disko.nixosModules.disko
    ./bootloader.nix
    ./bluetooth.nix
    ./disk-config.nix
    ./docker.nix
    ./dm
    ./hardware-configuration.nix
    ./hosts.nix
    # ./hybernation.nix
    ./kernel.nix
    ./keyboard.nix
    ./media.nix
    ./networking.nix
    ./nix.nix
    ./shell.nix
    ./stylix.nix
    ./timezone.nix
    ./users.nix
    ./video-graphics.nix
    ./wayland.nix
  ];
}
