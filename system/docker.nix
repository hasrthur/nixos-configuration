{ username, ... }:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    liveRestore = false; # TODO: check in some time
    # rootless = {
    #   enable = false;
    #   setSocketVariable = false;
    # };
  };

  users.extraGroups.docker.members = [ username ];
}