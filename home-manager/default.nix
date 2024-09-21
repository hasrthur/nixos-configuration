{ config, pkgs, username, ... }:

{
  imports = [
    ./autostart.nix
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
    # ./gnome
    ./plasma
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

    devcontainer

    vesktop
    slack
    telegram-desktop
    viber

    woeusb

    # (zoom-us.overrideAttrs (attrs: {
    #   nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [ pkgs.bbe ];
    #   postFixup = ''
    #     cp $out/opt/zoom/zoom .
    #     bbe -e 's/\0manjaro\0/\0nixos\0\0\0/' < zoom > $out/opt/zoom/zoom
    #   '' + (attrs.postFixup or "") + ''
    #     sed -i 's|Exec=|Exec=env XDG_CURRENT_DESKTOP="gnome" |' $out/share/applications/Zoom.desktop
    #   '';
    # }))
  ];

  programs.chromium.enable = true;

  programs.home-manager.enable = true;
}
