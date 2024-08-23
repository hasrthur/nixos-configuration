{ ... }:

{
  programs.plasma = {
    enable = true;

    panels = [
      {
        location = "bottom";
        widgets = [
          # Adding configuration to the widgets can also for example be used to
          # pin apps to the task-manager, which this example illustrates by
          # pinning dolphin and konsole to the task-manager by default with widget-specific options.
          {
            iconTasks = {
              launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:org.kde.konsole.desktop"
              ];
            };
          }
          # If no configuration is needed, specifying only the name of the
          # widget will add them with the default configuration.
          "org.kde.plasma.marginsseparator"
          # If you need configuration for your widget, instead of specifying the
          # the keys and values directly using the config attribute as shown
          # above, plasma-manager also provides some higher-level interfaces for
          # configuring the widgets. See modules/widgets for supported widgets
          # and options for these widgets. The widgets below shows two examples
          # of usage, one where we add a digital clock, setting 12h time and
          # first day of the week to Sunday and another adding a systray with
          # some modifications in which entries to show.


        ];
        hiding = "none";
      }
      # Application name, Global menu and Song information and playback controls at the top
      {
        location = "top";
        widgets = [
          {
            kickerdash = {
              behavior = {
                sortAlphabetically = true;
              };
            };
          }
          {
            applicationTitleBar = {
              behavior = {
                activeTaskSource = "activeTask";
              };
              layout = {
                elements = [ "windowTitle" ];
                horizontalAlignment = "left";
                showDisabledElements = "deactivated";
                verticalAlignment = "center";
              };
              overrideForMaximized.enable = false;
              titleReplacements = [
                {
                  type = "regexp";
                  originalTitle = "^Brave Web Browser$";
                  newTitle = "Brave";
                }
                {
                  type = "regexp";
                  originalTitle = ''\\bDolphin\\b'';
                  newTitle = "File manager";
                }
              ];
              windowTitle = {
                font = {
                  bold = false;
                  fit = "fixedSize";
                  size = 12;
                };
                hideEmptyTitle = true;
                margins = {
                  bottom = 0;
                  left = 10;
                  right = 5;
                  top = 0;
                };
                source = "appName";
              };
            };
          }
          "org.kde.plasma.appmenu"
          "org.kde.plasma.panelspacer"
          {
            plasmusicToolbar = {
              panelIcon = {
                albumCover = {
                  useAsIcon = false;
                  radius = 8;
                };
                icon = "view-media-track";
              };
              preferredSource = "spotify";
              musicControls.showPlaybackControls = true;
              songText = {
                displayInSeparateLines = true;
                maximumWidth = 640;
                scrolling = {
                  behavior = "alwaysScroll";
                  speed = 3;
                };
              };
            };
          }
          {
            systemTray = {
              items = {
                shown = [
                  "org.kde.plasma.volume"
                ];
                hidden = [
                  "org.kde.plasma.networkmanagement"
                  "org.kde.plasma.battery"
                  "org.kde.plasma.bluetooth"
                ];
              };
            };
          }
          {

            name = "org.kde.plasma.systemmonitor.cpucore";
            config = {
              # "org.kde.ksysguard.barchart" = {
              #   General = {
              #     horizontalBars = "true";
              #   };
              # };
              # General = {
              #   horizontalBars = true;
              # };
            };
            extraConfig = ''
              (widget) => {

                widget.currentConfigGroup = ["org.kde.ksysguard.barchart", "General"];
                widget.writeConfig("horizontalBars", true);
              }
            '';
          }
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              time.format = "24h";
            };
          }
        ];
      }
    ];
  };
}
