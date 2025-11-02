{ ... }:

{
  programs.nh = {
    enable = true;
    flake = ".nixos";
    clean = {
      enable = true;
      extraArgs = "--keep 5";
    };
  };
}
