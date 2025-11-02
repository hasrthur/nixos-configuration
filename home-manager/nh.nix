{ username, ... }:

{
  programs.nh = {
    enable = true;
    flake = "/home/${username}/.nixos";
    clean = {
      enable = true;
      extraArgs = "--keep 5";
    };
  };
}
