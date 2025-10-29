{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      localhost.addKeysToAgent = "yes";
    };
  };

  services.ssh-agent.enable = true;
}
