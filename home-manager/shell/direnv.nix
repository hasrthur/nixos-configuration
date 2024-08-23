{ ... }:

{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    config = {
      global = {
        warn_timeout = 0;
        disable_stdin = true;
        hide_env_diff = true;
      };
    };
  };
}