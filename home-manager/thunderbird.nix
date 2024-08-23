{ username, pkgs, ... }:

{
  programs.thunderbird = {
    enable = true;
    profiles.${username} = {
      isDefault = true;
    };
  };

  home.packages = with pkgs; [
    birdtray
  ];

  # accounts.email.accounts."arthur.borisow@gmail.com".thunderbird.enable = true;
  # accounts.email.accounts."artur.b@gatekeeperhq.com".thunderbird.enable = true;
}