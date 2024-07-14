{ pkgs, ...}:

{
  # fc-list to list all the fonts installed
  fonts.packages = with pkgs; [
    nerdfonts
  ];
}