{ ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = (builtins.fromTOML (builtins.readFile ./yazi.toml));
  };

  programs.zoxide.enable = true;
}
