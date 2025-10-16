{ lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    profiles = {
      default = {
        userSettings = builtins.fromJSON (builtins.readFile ./settings.json);
        keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);
      };
    };
  };
}
