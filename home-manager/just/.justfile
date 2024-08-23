nixos-rebuild *ARGS:
    -@sudo nixos-rebuild switch --show-trace --verbose {{ARGS}}

nixos-update *ARGS:
    -@nix flake update ~/.nixos

dconf:
    -@dconf dump / | dconf2nix > ~/.nixos/home-manager/gnome/dconf.nix
