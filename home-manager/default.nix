{ config, pkgs, username, ... }:

{
  imports = [
    # ./wm
    ./shell
    ./kitty
    ./stylix.nix
    ./ssh.nix
    ./vscode
    ./yazi
    ./git.nix
    ./thunderbird.nix
    ./just
    ./gnome
    # ./plasma.nix
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
    vesktop
    slack
    zoom-us
    devcontainer
  ];

  programs.chromium.enable = true;

  programs.home-manager.enable = true;
}
