{ ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    dotDir = ".config/zsh";
    initExtra = ''
    alias cat=bat
    '';
    loginExtra = ''
    ssh-add ~/.ssh/github
    '';
  };
}