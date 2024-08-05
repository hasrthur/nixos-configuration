{ config, pkgs, username, ... }:

{
  imports = [
    ./wm
    ./shell
    ./kitty
    ./stylix.nix
    ./ssh.nix
    ./vscode
    ./yazi
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
    gcc
    wl-clipboard
    hyprshot
    bitwarden-desktop
  ];

  programs.foot.enable = true;
  programs.kitty.enable = true;

  programs.git = {
    enable = true;
    userName = "Artur Borysov";
    userEmail = "arthur.borisow@gmail.com";
    diff-so-fancy.enable = true;
  };

  programs.firefox.enable = true;

  programs.home-manager.enable = true;

  services.dunst.enable = true;
  services.udiskie.enable = true;

  services.cliphist.enable = true;
}
