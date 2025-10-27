{ ... }:

{
  xdg.configFile = {
    "uwsm/env" = {
      text = builtins.readFile ./env;
    };

    "uwsm/env-hyprland" = {
      text = builtins.readFile ./env-hyprland;
    };
  };
}
