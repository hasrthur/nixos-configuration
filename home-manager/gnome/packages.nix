{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (dconf2nix.overrideAttrs {
      src = fetchgit {
        url = "https://github.com/gvolpe/dconf2nix.git";
        sha256 = "sha256-Pnl8Jy50XF9cMpo6imbzVWkiyGPUGvN21QtvEhs+P3k=";
        rev = "d9c960e87336b7c42b3e80f7ed4e5d56f8a3e107";
        fetchSubmodules = true;
      };
    })

    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
  ];
}
