{ nixpkgs, pkgs, inputs, ... }:

{
  imports = [
    ./bash.nix
    ./claude-code.nix
    ./direnv.nix
    ./starship.nix
    ./zsh.nix
  ];
}
