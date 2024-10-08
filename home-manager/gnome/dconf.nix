# Generated via dconf2nix: https://github.com/nix-commmunity/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "apps/seahorse/listing" = {
      keyrings-selected = [ "secret-service:///org/freedesktop/secrets/collection/login" ];
    };

    "apps/seahorse/windows/key-manager" = {
      height = 476;
      width = 600;
    };

    "org/gnome/Console" = {
      last-window-maximised = true;
      last-window-size = mkTuple [ 732 504 ];
    };

    "org/gnome/Extensions" = {
      window-height = 815;
      window-width = 1098;
    };

    "org/gnome/Geary" = {
      migrated-config = true;
      run-in-background = true;
      single-key-shortcuts = true;
      window-maximize = true;
    };

    "org/gnome/Music" = {
      window-maximized = true;
    };

    "org/gnome/Weather" = {
      locations = [ (mkVariant (mkTuple [ (mkUint32 2) (mkVariant (mkTuple [ "Kyiv" "UKKK" true [ (mkTuple [ 0.879675 0.531482 ]) ] [ (mkTuple [ 0.880228 0.532616 ]) ] ])) ])) ];
      window-height = 488;
      window-maximized = false;
      window-width = 992;
    };

    "org/gnome/calendar" = {
      active-view = "month";
      window-maximized = true;
      window-size = mkTuple [ 768 600 ];
    };

    "org/gnome/control-center" = {
      last-panel = "sound";
      window-state = mkTuple [ 980 640 false ];
    };

    "org/gnome/desktop/a11y/applications" = {
      screen-reader-enabled = false;
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Utilities" "YaST" "Pardus" ];
    };

    "org/gnome/desktop/app-folders/folders/Pardus" = {
      categories = [ "X-Pardus-Apps" ];
      name = "X-Pardus-Apps.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.Loupe.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop" ];
      categories = [ "X-GNOME-Utilities" ];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = [ "X-SuSE-YaST" ];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///nix/store/jhzl9lwdbr6njjvhplm9lpg7r6vlslgw-CuteCat.png";
      picture-uri-dark = "file:///nix/store/jhzl9lwdbr6njjvhplm9lpg7r6vlslgw-CuteCat.png";
    };

    "org/gnome/desktop/datetime" = {
      automatic-timezone = false;
    };

    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
      per-window = true;
      show-all-sources = false;
      sources = [ (mkTuple [ "xkb" "us" ]) (mkTuple [ "xkb" "ua" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-size = 32;
      cursor-theme = "Vanilla-DMZ";
      document-font-name = "CaskaydiaCove Nerd Font Propo  11";
      enable-animations = true;
      enable-hot-corners = false;
      font-name = "CaskaydiaCove Nerd Font Propo 12";
      gtk-theme = "adw-gtk3";
      icon-theme = "Papirus-Dark";
      monospace-font-name = "CaskaydiaCove Nerd Font Propo 12";
      scaling-factor = mkUint32 1;
      text-scaling-factor = 1.0;
      toolbar-style = "text";
    };

    "org/gnome/desktop/media-handling" = {
      autorun-never = true;
      autorun-x-content-ignore = [ "x-content/audio-cdda" ];
      autorun-x-content-open-folder = [];
      autorun-x-content-start-app = [ "x-content/unix-software" "x-content/ostree-repository" ];
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "org-gnome-console" "code-url-handler" "thunderbird" "slack" "org-gnome-geary" "vesktop" "chromium-browser" ];
    };

    "org/gnome/desktop/notifications/application/chromium-browser" = {
      application-id = "chromium-browser.desktop";
    };

    "org/gnome/desktop/notifications/application/code-url-handler" = {
      application-id = "code-url-handler.desktop";
    };

    "org/gnome/desktop/notifications/application/code" = {
      application-id = "code.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-extensions" = {
      application-id = "org.gnome.Extensions.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-geary" = {
      application-id = "org.gnome.Geary.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-settings" = {
      application-id = "org.gnome.Settings.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-tweaks" = {
      application-id = "org.gnome.tweaks.desktop";
    };

    "org/gnome/desktop/notifications/application/slack" = {
      application-id = "slack.desktop";
    };

    "org/gnome/desktop/notifications/application/thunderbird" = {
      application-id = "thunderbird.desktop";
    };

    "org/gnome/desktop/notifications/application/vesktop" = {
      application-id = "vesktop.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "default";
      speed = -5.4054e-2;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = [ "org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" ];
    };

    "org/gnome/desktop/sound" = {
      theme-name = "ocean";
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ "<Control>space" ];
      switch-input-source-backward = [ "<Shift><Control>space" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "icon:minimize,maximize,close";
      mouse-button-modifier = "<Alt>";
      num-workspaces = 7;
    };

    "org/gnome/epiphany" = {
      ask-for-default = false;
    };

    "org/gnome/epiphany/state" = {
      is-maximized = false;
      window-size = mkTuple [ 1024 768 ];
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/gnome-system-monitor" = {
      cpu-colors = [ (mkTuple [ (mkUint32 0) "#e01b24" ]) (mkTuple [ 1 "#ff7800" ]) (mkTuple [ 2 "#f6d32d" ]) (mkTuple [ 3 "#33d17a" ]) (mkTuple [ 4 "#26a269" ]) (mkTuple [ 5 "#62a0ea" ]) (mkTuple [ 6 "#1c71d8" ]) (mkTuple [ 7 "#613583" ]) (mkTuple [ 8 "#9141ac" ]) (mkTuple [ 9 "#c061cb" ]) (mkTuple [ 10 "#ffbe6f" ]) (mkTuple [ 11 "#f9f06b" ]) (mkTuple [ 12 "#8ff0a4" ]) (mkTuple [ 13 "#2ec27e" ]) (mkTuple [ 14 "#1a5fb4" ]) (mkTuple [ 15 "#c061cb" ]) (mkTuple [ 16 "#7a23f3327999" ]) (mkTuple [ 17 "#f33279999d9f" ]) (mkTuple [ 18 "#7999c11af332" ]) (mkTuple [ 19 "#e495f3327999" ]) (mkTuple [ 20 "#de537999f332" ]) (mkTuple [ 21 "#7999f332bad7" ]) (mkTuple [ 22 "#f332975c7999" ]) (mkTuple [ 23 "#79997f51f332" ]) (mkTuple [ 24 "#a2ccf3327999" ]) (mkTuple [ 25 "#f3327999c647" ]) (mkTuple [ 26 "#7999e9c3f332" ]) (mkTuple [ 27 "#f332d9257999" ]) (mkTuple [ 28 "#b5aa7999f332" ]) (mkTuple [ 29 "#7999f332922f" ]) (mkTuple [ 30 "#f3327999847e" ]) (mkTuple [ 31 "#7999a7f9f332" ]) ];
      show-dependencies = false;
      show-whose-processes = "user";
      window-width = 1159;
    };

    "org/gnome/gnome-system-monitor/disktreenew" = {
      col-6-visible = true;
      col-6-width = 0;
    };

    "org/gnome/gnome-system-monitor/proctree" = {
      col-0-visible = true;
      col-0-width = 1872;
    };

    "org/gnome/mutter" = {
      edge-tiling = true;
      experimental-features = [ "scale-monitor-framebuffer" ];
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "suspend";
    };

    "org/gnome/shell" = {
      disabled-extensions = [ "launch-new-instance@gnome-shell-extensions.gcampax.github.com" "light-style@gnome-shell-extensions.gcampax.github.com" "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com" "user-theme@gnome-shell-extensions.gcampax.github.com" "window-list@gnome-shell-extensions.gcampax.github.com" "workspace-indicator@gnome-shell-extensions.gcampax.github.com" "apps-menu@gnome-shell-extensions.gcampax.github.com" "places-menu@gnome-shell-extensions.gcampax.github.com" ];
      enabled-extensions = [ "drive-menu@gnome-shell-extensions.gcampax.github.com" "system-monitor@gnome-shell-extensions.gcampax.github.com" "native-window-placement@gnome-shell-extensions.gcampax.github.com" "windowsNavigator@gnome-shell-extensions.gcampax.github.com" "auto-move-windows@gnome-shell-extensions.gcampax.github.com" "dash-to-dock@micxgx.gmail.com" "appindicatorsupport@rgcjonas.gmail.com" "just-perfection-desktop@just-perfection" "NotificationCounter@coolllsk" "trayIconsReloaded@selfmade.pl" ];
      favorite-apps = [ "org.gnome.Geary.desktop" "chromium-browser.desktop" "org.gnome.Calendar.desktop" "org.gnome.Music.desktop" "org.gnome.Nautilus.desktop" ];
      last-selected-power-profile = "performance";
      welcome-dialog-last-shown-version = "46.4";
    };

    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = [ "chromium-browser.desktop:3" "code.desktop:2" "org.gnome.Console.desktop:1" "slack.desktop:4" "vesktop.desktop:6" "geary-autostart.desktop:7" "org.gnome.Geary.desktop:7" ];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      always-center-icons = true;
      apply-custom-theme = false;
      apply-glossy-effect = false;
      background-opacity = 0.0;
      custom-theme-shrink = true;
      dash-max-icon-size = 32;
      disable-overview-on-startup = false;
      dock-position = "BOTTOM";
      extend-height = false;
      height-fraction = 0.9;
      hide-tooltip = false;
      hot-keys = false;
      icon-size-fixed = false;
      intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
      isolate-monitors = false;
      isolate-workspaces = false;
      multi-monitor = true;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "DP-1";
      preview-size-scale = 1.0;
      running-indicator-style = "DOTS";
      scroll-action = "switch-workspace";
      scroll-to-focused-application = true;
      show-apps-always-in-the-edge = true;
      show-apps-at-top = false;
      show-favorites = true;
      show-mounts-network = false;
      show-running = true;
      show-show-apps-button = true;
      show-trash = false;
      show-windows-preview = true;
      transparency-mode = "FIXED";
      unity-backlit-items = false;
      workspace-agnostic-urgent-windows = true;
    };

    "org/gnome/shell/extensions/just-perfection" = {
      accessibility-menu = true;
      activities-button = true;
      animation = 3;
      clock-menu = true;
      clock-menu-position = 0;
      controls-manager-spacing-size = 0;
      dash = true;
      dash-app-running = true;
      dash-separator = true;
      keyboard-layout = true;
      notification-banner-position = 2;
      osd = true;
      overlay-key = true;
      panel = true;
      panel-notification-icon = true;
      power-icon = true;
      quick-settings = true;
      quick-settings-dark-mode = true;
      show-apps-button = true;
      startup-status = 0;
      window-maximized-on-create = false;
      window-picker-icon = true;
      window-preview-close-button = true;
      workspace = true;
      workspace-switcher-should-show = true;
      workspace-switcher-size = 0;
      workspace-wrap-around = false;
      workspaces-in-app-grid = true;
      world-clock = true;
    };

    "org/gnome/shell/extensions/system-monitor" = {
      show-swap = false;
    };

    "org/gnome/shell/extensions/trayIconsReloaded" = {
      applications = "[{\"id\":\"slack.desktop\",\"hidden\":false},{\"id\":\"org.gnome.Geary.desktop\"}]";
      tray-position = "right";
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "Stylix";
    };

    "org/gnome/shell/weather" = {
      automatic-location = true;
      locations = [ (mkVariant (mkTuple [ (mkUint32 2) (mkVariant (mkTuple [ "Kyiv" "UKKK" true [ (mkTuple [ 0.879675 0.531482 ]) ] [ (mkTuple [ 0.880228 0.532616 ]) ] ])) ])) ];
    };

    "org/gnome/shell/world-clocks" = {
      locations = [];
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 227;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 0 0 ];
      window-size = mkTuple [ 948 468 ];
    };

  };
}
