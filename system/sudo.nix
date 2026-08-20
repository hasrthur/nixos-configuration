{ ... }:

{
  # Enable passwordless sudo for wheel group members
  # This is required for nh to activate system configurations
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
}
