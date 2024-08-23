{ username, ... }:

{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # hardware.pulseaudio.enable = true;
  # hardware.pulseaudio.support32Bit = true;

  users.extraUsers.${username}.extraGroups = [ "audio" ];
}