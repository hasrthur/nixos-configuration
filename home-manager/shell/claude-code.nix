{ pkgs, ... }:

let
  # An interactive zsh exports PINENTRY_USER_DATA=USE_TTY=1 (see shell/zsh.nix)
  # so gpg-agent picks pinentry-curses. Claude Code inherits that, but the shells
  # it spawns for tool calls have no controlling terminal — pinentry-curses then
  # draws the passphrase prompt straight onto the pts hosting the TUI, which
  # corrupts the display and makes signed commits impossible. Drop the hint so
  # gpg-agent falls back to the graphical pinentry (see gpg.nix).
  claude-code = pkgs.symlinkJoin {
    name = "claude-code-${pkgs.claude-code.version}";
    paths = [ pkgs.claude-code ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/claude --unset PINENTRY_USER_DATA
    '';
  };
in

{
  home.packages = [ claude-code ];
}
