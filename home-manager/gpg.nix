{ pkgs, ... }:

{
  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = with pkgs; (writeShellApplication {
      name = "pinentry-auto";
      runtimeInputs = [
        pinentry-curses
        pinentry-rofi
      ];
      text = ''
        set -Ceu

        case "''${PINENTRY_USER_DATA-}" in
        *USE_TTY=1*)
          exec pinentry-curses "$@"
          ;;
        esac

        exec pinentry-rofi "$@"
      '';
    });
  };
}
