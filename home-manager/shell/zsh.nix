{ config, ... }:

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
    '';
  };
}
