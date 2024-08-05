{ ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = ".config/zsh";
    initExtra = ''
    alias cat=bat

    ssh-add ~/.ssh/github &> /dev/null
    '';
  };
}