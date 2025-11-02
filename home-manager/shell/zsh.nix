{ config, username, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = config.home.homeDirectory + "/.config/zsh";
    initContent = ''
      alias cat=bat

      export PATH=/home/artur/.local/share/JetBrains/Toolbox/scripts:$PATH

      ssh-add ~/.ssh/github &> /dev/null

      set -o emacs

      if [ -t 0 ]; then
        export GPG_TTY="$(tty)"
        export PINENTRY_USER_DATA=USE_TTY=1
      fi
    '';
  };

  home.shell.enableZshIntegration = true;
}
