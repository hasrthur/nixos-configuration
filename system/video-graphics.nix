{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    open = false;
    modesetting.enable = true;
    powerManagement.enable = true;
  };

  # boot.kernelParams = [ "nvidia.NVreg_EnableGpuFirmware=0" ];
  # hardware.graphics = {
  #  enable = true;
  #  extraPackages = with pkgs; [
  #     vpl-gpu-rt          # for newer GPUs on NixOS >24.05 or unstable
  #     # onevpl-intel-gpu  # for newer GPUs on NixOS <= 24.05
  #     # intel-media-sdk   # for older GPUs
  #  ];
  # };
}
