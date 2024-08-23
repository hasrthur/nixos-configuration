{ pkgs, ... }:

{
  home.packages = with pkgs; [
    just
  ];

  home.file.".justfile".source = ./.justfile;
}