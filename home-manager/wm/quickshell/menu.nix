# The menu tree.
#
# Authored here rather than in QML so it survives a rewrite of the drawing layer,
# and so it can be commented and reviewed like the rest of this config. Omarchy
# keeps the same shape in JSONC; the mechanics are theirs, the routes are ours.
#
# Dotted ids imply hierarchy: "system.lock" sits under "system". Kind is inferred
# — `provider` means rows come from the shell at runtime, `action` means run a
# command, anything else is a submenu.
#
# Their install/remove/update trees are deliberately absent: pacman and the AUR
# have no equivalent here, and `nix.*` covers what replaces them. Their
# style.theme and style.font routes are absent too, since Stylix owns both and a
# menu that fought it could only lie.
{
  apps = { icon = "󰀻"; label = "Apps"; provider = "apps"; };

  nix = { icon = "󱄅"; label = "Nix"; };
  "nix.test" = {
    icon = "󰑓";
    label = "Rebuild (no generation)";
    action = "wm-terminal-run nh os test";
  };
  "nix.switch" = {
    icon = "󰚰";
    label = "Rebuild and switch";
    action = "wm-terminal-run nh os switch";
  };
  "nix.boot" = {
    icon = "󰜉";
    label = "Rebuild for next boot";
    action = "wm-terminal-run nh os boot";
  };
  "nix.clean" = {
    icon = "󰩹";
    label = "Collect garbage";
    action = "wm-terminal-run nh clean all --keep 5";
  };
  "nix.generations" = {
    icon = "󰋚";
    label = "List generations";
    action = "wm-terminal-run nixos-rebuild list-generations";
  };

  notifications = { icon = "󰂚"; label = "Notifications"; };
  "notifications.history" = {
    icon = "󰋚";
    label = "Replay history";
    action = "wm-shell notifications showHistory";
  };
  "notifications.dnd" = {
    icon = "󰂛";
    label = "Toggle silencing";
    action = "wm-shell notifications toggleSilence";
  };
  "notifications.clear" = {
    icon = "󰎟";
    label = "Clear history";
    action = "wm-shell notifications clearHistory";
  };

  audio = { icon = "󰕾"; label = "Audio"; };
  "audio.output" = {
    icon = "󰓃";
    label = "Next output device";
    action = "wm-audio-output-switch";
  };
  "audio.mute" = {
    icon = "󰝟";
    label = "Toggle mute";
    action = "wm-audio-output-volume mute-toggle";
  };
  "audio.mic" = {
    icon = "󰍬";
    label = "Toggle microphone";
    action = "wm-audio-input-mute";
  };

  system = { icon = "󰐥"; label = "System"; };
  "system.lock" = { icon = "󰌾"; label = "Lock"; action = "loginctl lock-session"; };
  "system.suspend" = { icon = "󰒲"; label = "Suspend"; action = "systemctl suspend"; };
  "system.logout" = { icon = "󰍃"; label = "Log out"; action = "uwsm stop"; };
  "system.reboot" = { icon = "󰜉"; label = "Reboot"; action = "systemctl reboot"; };
  "system.shutdown" = { icon = "󰐥"; label = "Shut down"; action = "systemctl poweroff"; };
}
