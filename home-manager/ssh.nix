{ ... }:

{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      localhost.addKeysToAgent = "yes";
    };
  };

  services.ssh-agent.enable = true;
}
