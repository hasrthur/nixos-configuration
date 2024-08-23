{ lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
    userSettings = builtins.fromJSON (builtins.readFile ./settings.json);
  };
}