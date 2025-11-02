nixos-repair:
    -@sudo nix-store --verify --check-contents --repair

dconf:
    -@dconf dump / | dconf2nix > ~/.nixos/home-manager/gnome/dconf.nix
