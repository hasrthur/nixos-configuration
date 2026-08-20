{ ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "yy";
    settings = (builtins.fromTOML (builtins.readFile ./yazi.toml));
  };

  programs.zoxide.enable = true;
}
