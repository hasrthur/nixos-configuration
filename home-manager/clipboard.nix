{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
  ];

  services = {
    cliphist.enable = true;
    wl-clip-persist.enable = true;
  };
}
