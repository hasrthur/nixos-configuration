{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    xarchiver
  ];

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
}