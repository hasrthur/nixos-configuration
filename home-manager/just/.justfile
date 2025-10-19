nixos-rebuild *ARGS:
    -@sudo nixos-rebuild switch --flake ~/.nixos --show-trace --verbose {{ARGS}}

nixos-update *ARGS:
    -@nix flake update --flake ~/.nixos

nixos-repair:
    -@sudo nix-store --verify --check-contents --repair

dconf:
    -@dconf dump / | dconf2nix > ~/.nixos/home-manager/gnome/dconf.nix
