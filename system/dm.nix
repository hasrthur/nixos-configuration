{ pkgs, ... }:

{
  nixpkgs.overlays = [
    # GNOME 46: triple-buffering-v4-46
    (final: prev: {
      gnome = prev.gnome.overrideScope (gnomeFinal: gnomePrev: {
        mutter = gnomePrev.mutter.overrideAttrs (old: {
          src = pkgs.fetchFromGitLab  {
            domain = "gitlab.gnome.org";
            owner = "vanvugt";
            repo = "mutter";
            rev = "triple-buffering-v4-46";
            hash = "sha256-C2VfW3ThPEZ37YkX7ejlyumLnWa9oij333d5c4yfZxc=";
          };
        });
      });
    })
  ];

  # service.displayManager
  services = {
    # desktopManager.plasma6.enable = true;
    # displayManager = {
    #   sddm = {
    #     enable = true;
    #     wayland.enable = true;
    #   };
    # };

    xserver.displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    xserver.desktopManager.gnome.enable = true;

    xserver = {
      enable = true;

      xkb = {
        layout = "us,ua";
        options = "grp:ctrl_space_toggle";
      };
    };
  };

  hardware.pulseaudio.enable = false;
}
