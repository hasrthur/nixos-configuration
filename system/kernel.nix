{ pkgs, ...}:

{
  # nvidia won't compile with latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}