{ username, ... }:

{
  users.users."${username}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ]; # Enable ‘sudo’ for the user.
  };

  # services.getty.autologinUser = username;
}
