{ config, pkgs, username, ... }:

{
  imports = [
    ./wm
    ./shell
    ./wezterm
  ];

  xdg.enable = true;

  home = {
    username = username;
    homeDirectory = "/home/${username}";
  };

  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    bat
    vim
    tig
    devenv
    lxqt.lxqt-policykit
  ];

  programs.git = {
    enable = true;
    userName = "Artur Borysov";
    userEmail = "arthur.borisow@gmail.com";
    diff-so-fancy.enable = true;
  };

  

  programs.vscode.enable = true;
  programs.firefox.enable = true;

  

  programs.home-manager.enable = true;

  services.dunst.enable = true;
}