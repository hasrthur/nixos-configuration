{ ... }:

{
  programs.plasma.panels = [
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
            # preferredSource = "spotify";
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
        "org.kde.plasma.systemmonitor.cpucore"
        "org.kde.plasma.systemmonitor.memory"
        "org.kde.plasma.systemmonitor.net"
        {
          digitalClock = {
            calendar.firstDayOfWeek = "monday";
            time.format = "24h";
          };
        }
      ];
    }
  ];
}
