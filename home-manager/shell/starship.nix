{ ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      command_timeout = 50000;
      git_status = {
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
      };
      git_metrics.disabled = false;
      status.disabled = false;
      sudo.disabled = false;
      direnv.disabled = false;
      directory.truncate_to_repo = false;
      docker_context = {
        only_with_files = false;
        disabled = false;
      };
    };
  };
}